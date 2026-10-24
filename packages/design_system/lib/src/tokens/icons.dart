import 'package:flutter/material.dart';

/// The semantic icon set.
///
/// One glyph per concept, chosen once, so a screen never hand-picks a Material
/// icon for a domain idea and two screens never disagree about what an issue
/// or a branch looks like. CI job states are the one exception — they live in
/// `CiStatusIcon`, which pairs each state's glyph with its colour.
abstract final class LabFoxIcons {
  // ── Work items ──────────────────────────────────────────────────────────
  static const IconData issueOpen = Icons.adjust;
  static const IconData issueClosed = Icons.check_circle_outline;
  static const IconData mergeRequest = Icons.merge_outlined;
  static const IconData merged = Icons.merge;

  /// A closed-without-merging merge request.
  static const IconData closed = Icons.close;

  // ── Repository ──────────────────────────────────────────────────────────
  static const IconData project = Icons.folder_outlined;
  static const IconData group = Icons.people_outline;
  static const IconData repository = Icons.folder_copy_outlined;
  static const IconData branch = Icons.account_tree_outlined;
  static const IconData commit = Icons.commit;
  static const IconData history = Icons.history;
  static const IconData code = Icons.code;
  static const IconData file = Icons.insert_drive_file_outlined;
  static const IconData document = Icons.description_outlined;
  static const IconData diff = Icons.difference_outlined;
  static const IconData label = Icons.label_outline;
  static const IconData release = Icons.new_releases_outlined;
  static const IconData containerRegistry = Icons.widgets_outlined;
  static const IconData packageRegistry = Icons.inventory_2_outlined;
  static const IconData milestone = Icons.flag_outlined;
  static const IconData environment = Icons.cloud_outlined;

  // ── CI ──────────────────────────────────────────────────────────────────
  static const IconData pipeline = Icons.rocket_launch_outlined;

  // ── Inbox and social ────────────────────────────────────────────────────
  static const IconData inbox = Icons.inbox_outlined;
  static const IconData notification = Icons.notifications_outlined;
  static const IconData comment = Icons.mode_comment_outlined;
  static const IconData approval = Icons.thumb_up_outlined;

  // ── Attributes ──────────────────────────────────────────────────────────
  static const IconData private = Icons.lock_outline;
  static const IconData public = Icons.public;
  static const IconData star = Icons.star;
  static const IconData starBorder = Icons.star_border;
  static const IconData fork = Icons.call_split;

  // ── Actions ─────────────────────────────────────────────────────────────
  static const IconData search = Icons.search;
  static const IconData searchOff = Icons.search_off;
  static const IconData add = Icons.add;
  static const IconData close = Icons.close;
  static const IconData check = Icons.check;
  static const IconData doneAll = Icons.done_all;
  static const IconData refresh = Icons.refresh;
  static const IconData share = Icons.ios_share;
  static const IconData openInBrowser = Icons.open_in_browser;
  static const IconData edit = Icons.edit_outlined;
  static const IconData copy = Icons.copy_all_outlined;

  // ── Navigation and account ──────────────────────────────────────────────
  static const IconData chevron = Icons.chevron_right;
  static const IconData dropdown = Icons.arrow_drop_down;
  static const IconData person = Icons.person_outline;
  static const IconData account = Icons.account_circle_outlined;
  static const IconData switchAccount = Icons.switch_account_outlined;
  static const IconData settings = Icons.settings_outlined;
  static const IconData signOut = Icons.logout;
}
