"""Synthetic profile contract checks. No model calls or installed profile writes."""
import copy
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest

PLUGIN = Path(__file__).resolve().parents[2]
HOOK = PLUGIN / 'hooks/check-model-profiles.sh'
EXAMPLE = (PLUGIN / 'model-profiles.example.md').read_text()


class ProfileGuardTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls):
        blocks = re.findall(r'^```yaml\n(.*?)^```$', EXAMPLE, re.M | re.S)
        cls.data = json.loads(subprocess.check_output(
            ['yq', '-o=json', '.'], input='\n'.join(blocks), text=True))

    def setUp(self):
        self.tmp = tempfile.TemporaryDirectory()
        self.addCleanup(self.tmp.cleanup)
        self.profile = Path(self.tmp.name) / 'profile.md'
        self.data = copy.deepcopy(self.data)

    def check(self, message=None, text=None, env=None):
        if text is None:
            text = '```yaml\n' + json.dumps(self.data) + '\n```\n'
        self.profile.write_text(text)
        result = subprocess.run(['/bin/bash', str(HOOK), str(self.profile)],
                                capture_output=True, text=True, env=env, timeout=5)
        self.assertEqual(result.returncode, 0, result.stderr)
        self.assertEqual(result.stderr, '')
        if message is None:
            self.assertEqual(result.stdout, '')
        else:
            payload = json.loads(result.stdout)['hookSpecificOutput']
            self.assertEqual(payload['hookEventName'], 'SessionStart')
            self.assertIn(message, payload['additionalContext'])

    def test_committed_example_is_silent(self):
        self.check(text=EXAMPLE)

    def legacy(self):
        for profile in self.data.values():
            if isinstance(profile, dict) and 'api_verified' in profile:
                profile.pop('model_id')
                profile.pop('delegation_alias')
        for key in ('reassess_when', 'reassess'):
            self.data['execution_signals'].pop(key)
        self.data['execution_signals']['escalate_when'] = [
            'repeated failures', 'investigation running longer than one hour']

    def test_legacy_profile_upgrade_is_silent(self):
        self.legacy()
        self.check()

    def test_legacy_duplicate_tier_warns(self):
        self.legacy()
        self.data['duplicate-profile'] = copy.deepcopy(self.data['sonnet-5'])
        self.check('legacy tier execution must have exactly one candidate profile (found 2)')

    def test_legacy_missing_profile_warns(self):
        self.legacy()
        del self.data['sonnet-5']
        self.check('legacy tier execution must have exactly one candidate profile (found 0)')

    def test_partial_identity_extension_warns(self):
        self.legacy()
        self.data['sonnet-5']['model_id'] = self.data['tier_to_model']['execution']
        self.check('profile identity extension is incomplete')

    def test_alias_only_extension_warns(self):
        self.legacy()
        self.data['sonnet-5']['delegation_alias'] = 'sonnet'
        self.check('profile identity extension is incomplete')

    def test_identity_without_reassessment_extension_is_silent(self):
        for key in ('reassess_when', 'reassess'):
            del self.data['execution_signals'][key]
        self.check()

    def test_reassessment_without_identity_extension_is_silent(self):
        signals = copy.deepcopy(self.data['execution_signals'])
        self.legacy()
        self.data['execution_signals'] = signals
        self.check()

    def test_one_profile_missing_identity_warns(self):
        del self.data['sonnet-5']['model_id']
        self.check('profile identity extension is incomplete')

    def test_legacy_partial_reassessment_warns(self):
        self.legacy()
        self.data['execution_signals']['reassess'] = 'Check authority and evidence.'
        self.check('execution_signals.reassess_when` is missing')

    def test_legacy_identity_is_not_certified(self):
        self.legacy()
        self.data['tier_to_model']['execution'] = 'unprofiled-model'
        # Legacy structural acceptance cannot certify identity. Consumers must
        # withhold profile advice until its key/source matches the target.
        self.check()

    def test_missing_file_warns(self):
        result = subprocess.run(['/bin/bash', str(HOOK), str(self.profile)],
                                capture_output=True, text=True, timeout=5)
        self.assertEqual(result.returncode, 0)
        self.assertIn('MISSING', json.loads(result.stdout)
                      ['hookSpecificOutput']['additionalContext'])

    def test_empty_file_warns(self):
        self.check('no non-empty fenced yaml blocks', text='')

    def test_prose_only_warns(self):
        self.check('no non-empty fenced yaml blocks', text='profile accidentally cleared')

    def test_empty_fence_warns(self):
        self.check('no non-empty fenced yaml blocks', text='```yaml\n```\n')

    def test_empty_fence_before_valid_blocks_is_allowed(self):
        self.check(text='```yaml\n```\n' + EXAMPLE)

    def test_unclosed_fence_warns(self):
        self.check('unclosed yaml fence', text='```yaml\nkey: value\n')

    def test_missing_reassessment_contract(self):
        del self.data['execution_signals']['reassess']
        self.check('execution_signals.reassess` is missing')

    def test_malformed_yaml_warns(self):
        self.check('does not parse', text='```yaml\nbroken: [\n```\n')

    def test_required_policy_block_missing(self):
        del self.data['execution_signals']
        self.check('execution_signals` is missing')

    def test_policy_paths_are_top_level(self):
        for key in ('staleness_rule', 'context_cost_rule'):
            self.assertIsInstance(self.data[key], str)
            self.assertNotIn(key, self.data['meta'])
        self.data['meta']['context_cost_rule'] = self.data.pop('context_cost_rule')
        self.check('context_cost_rule` is missing')

    def test_note_accidentally_parsed_as_map(self):
        self.data['opus-5']['notes'].append({'code review': 'unquoted colon'})
        self.check('list item(s) parse as a map')

    def test_missing_alias(self):
        del self.data['delegation_aliases']['execution']
        self.check('delegation_aliases` covers')

    def test_invalid_alias(self):
        self.data['delegation_aliases']['execution'] = 'not-a-valid-alias'
        self.check('alias for execution does not match')

    def test_missing_profile(self):
        del self.data['sonnet-5']
        self.check('exactly one profile by model_id (found 0)')

    def test_new_model_cannot_reuse_previous_profile(self):
        self.data['tier_to_model']['execution'] = 'unprofiled-model'
        self.check('exactly one profile by model_id (found 0)')

    def test_duplicate_model_identity(self):
        self.data['duplicate-profile'] = copy.deepcopy(self.data['sonnet-5'])
        self.check('exactly one profile by model_id (found 2)')

    def test_profile_tier_mismatch(self):
        self.data['sonnet-5']['tier'] = 'deliberation'
        self.check('resolved profile has the wrong tier for execution')

    def test_missing_yq_reports_unavailable_validation(self):
        binaries = Path(self.tmp.name) / 'bin'
        binaries.mkdir()
        (binaries / 'python3').symlink_to(sys.executable)
        self.check('validation unavailable', env={**os.environ, 'PATH': str(binaries)})


if __name__ == '__main__':
    unittest.main()
