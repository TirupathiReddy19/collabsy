/// One `marketingTasks` doc — a lightweight, Jira-style ticket for the
/// marketing tracker (`collabsy-marketing`, a standalone site separate
/// from Admin/Brand Intern/Outreach): admin creates and assigns it,
/// `status` moves through `'todo' -> 'in_progress' -> 'done'`, and
/// [currentCount]/[targetCount] (both nullable — plenty of tasks are
/// plain status tickets with no number attached) let a quota-style task
/// like "send 200 DMs today" track a running count the assignee updates
/// by hand (this tool never auto-tracks anything from the actual
/// Outreach/Brand Intern tools). Only the assignee or admin may ever
/// touch `status`/`currentCount`; every other field is admin-only.
typedef MarketingTask = ({
  String id,
  String title,
  String description,
  String assigneeId,
  String assigneeEmail,
  String status,
  int? targetCount,
  int? currentCount,
  DateTime? dueDate,
  String createdBy,
  DateTime? createdAt,
  DateTime? updatedAt,
});
