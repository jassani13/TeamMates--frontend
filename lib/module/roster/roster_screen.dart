import 'add_staff_form.dart';

Column(
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Text('Players (${players.length})', style: TextStyle(fontWeight: FontWeight.bold)),
    ...players.map((p) => ListTile(title: Text(p.name))),
    SizedBox(height: 16),
    Text('Non-Players (${staff.length})', style: TextStyle(fontWeight: FontWeight.bold)),
    ...staff.map((s) => ListTile(title: Text(s.name), subtitle: Text(s.staffRole ?? ''))),
  ],
)

void _showAddStaffForm(BuildContext context, int teamId, Function onStaffAdded) {
  showDialog(
    context: context,
    builder: (context) => AddStaffForm(teamId: teamId, onStaffAdded: onStaffAdded),
  );
} 