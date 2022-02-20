import 'package:flutter/material.dart';
import 'package:kart_app/data/api.dart';
import 'package:kart_app/models/player.dart';
import 'package:kart_app/widgets/character_icon.dart';

class SubmitResultsPage extends StatefulWidget {
  const SubmitResultsPage({Key? key}) : super(key: key);

  @override
  _SubmitResultsPageState createState() => _SubmitResultsPageState();
}

class _SubmitResultsPageState extends State<SubmitResultsPage> {
  Map<Player, bool> _players = {};
  List<Player> _participants = [];

  void _refreshAllPlayers() async {
    final players = await Api.getAllPlayers();
    setState(() {
      for (final player in players) {
        _players.putIfAbsent(player, () => false);
      }
    });
  }

  void _confirmParticipants() {
    setState(() {
      _participants = _players.entries.where((entry) => entry.value).map((entry) => entry.key).toList();
    });
  }

  Future<void> _submitResults() async {
    final ids = _participants.map((player) => player.id).toList();
    await Api.submitResults(ids);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _refreshAllPlayers());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Nouvelle course')),
      body: _participants.isEmpty
          ? ListView(
              padding: const EdgeInsets.all(16.0),
              children: _players.entries
                  .map((entry) => CheckboxListTile(
                        title: Row(
                          children: [
                            CharacterIcon(icon: entry.key.icon),
                            SizedBox(width: 8.0),
                            Expanded(child: Text(entry.key.name)),
                          ],
                        ),
                        value: entry.value,
                        onChanged: (selected) {
                          setState(() {
                            _players[entry.key] = selected ?? false;
                          });
                        },
                      ))
                  .toList())
          : ReorderableListView(
              padding: const EdgeInsets.all(16.0),
              children: _participants
                  .map((player) => ListTile(
                        key: Key('${player.id}'),
                        leading: Text(
                          '${_participants.indexOf(player) + 1}',
                          style: Theme.of(context).textTheme.headline4,
                        ),
                        title: Text(player.name),
                      ))
                  .toList(),
              onReorder: (int oldIndex, int newIndex) {
                setState(() {
                  if (oldIndex < newIndex) {
                    newIndex -= 1;
                  }
                  final player = _participants.removeAt(oldIndex);
                  _participants.insert(newIndex, player);
                });
              },
            ),
      floatingActionButton: _participants.isEmpty
          ? FloatingActionButton(
              onPressed: _confirmParticipants,
              child: Icon(Icons.navigate_next),
            )
          : FloatingActionButton.extended(
              onPressed: _submitResults,
              icon: Icon(Icons.check),
              label: Text('Valider'),
            ),
    );
  }
}
