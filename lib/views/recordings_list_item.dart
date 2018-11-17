import 'package:chipkizi/models/main_model.dart';
import 'package:chipkizi/models/recording.dart';
import 'package:chipkizi/models/user.dart';
import 'package:chipkizi/pages/login.dart';

import 'package:chipkizi/pages/player.dart';

import 'package:chipkizi/values/status_code.dart';
import 'package:chipkizi/values/strings.dart';
import 'package:flutter/material.dart';
import 'package:scoped_model/scoped_model.dart';

const _tag = 'RecordingsListItemView:';

class RecordingsListItemView extends StatelessWidget {
  final Recording recording;
  final ListType type;
  final List<Recording> recordings;

  const RecordingsListItemView(
      {Key key, this.recording, this.type, this.recordings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    _goToLogin() => Navigator.push(context,
        MaterialPageRoute(builder: (_) => LoginPage(), fullscreenDialog: true));
    _handleAction(
        BuildContext context, MainModel model, RecordingActions action) {
      switch (action) {
        case RecordingActions.upvote:
          model.isLoggedIn
              ? model.hanldeUpvoteRecording(recording, model.currentUser)
              : _goToLogin();
          break;
        case RecordingActions.bookmark:
          model.isLoggedIn
              ? model.handleBookbarkRecording(recording, model.currentUser)
              : _goToLogin();
          break;
        default:
          print('$_tag the popup menu selected acion is: $action');
      }
    }

    Widget _buildLeadingSection(MainModel model) => FutureBuilder<User>(
          future: model.userFromId(recording.createdBy),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return Icon(Icons.mic);
            User user = snapshot.data;
            return CircleAvatar(
              radius: 24.0,
              backgroundColor: Colors.black12,
              backgroundImage: NetworkImage(user.imageUrl),
            );
          },
        );

    Widget _buildPopUpMenu(MainModel model) =>
        PopupMenuButton<RecordingActions>(
          onSelected: (action) => _handleAction(context, model, action),
          child: Icon(Icons.more_vert),
          itemBuilder: (BuildContext context) {
            return <PopupMenuItem<RecordingActions>>[
              // PopupMenuItem( child: Text(upvoteText),),
              PopupMenuItem(
                value: RecordingActions.upvote,
                child: Text(upvoteText),
              ),
              PopupMenuItem(
                value: RecordingActions.share,
                child: Text(shareText),
              ),
              PopupMenuItem(
                value: RecordingActions.bookmark,
                child: Text(bookmarkText),
              ),
            ];
          },
        );

    return ScopedModelDescendant<MainModel>(
      builder: (_, __, model) {
        List<Recording> _recordings = <Recording>[];
        switch (type) {
          case ListType.bookmarks:
          case ListType.userRecordings:
            _recordings = recordings;
            break;
          default:
            _recordings = model.getAllRecordings(recording);
        }

        Widget _buildChips(Icon icon, String label) => Container(
              child: Padding(
                padding: const EdgeInsets.all(2.0),
                child: Row(
                  children: <Widget>[
                    icon,
                    Text(
                      label,
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            );

        final _playLikeSection = recording.playCount == 0 && recording.upvoteCount == 0 ?
        Container(): Container(
          padding: const EdgeInsets.all(2.0),
          decoration: BoxDecoration(
              color: Colors.brown,
              borderRadius: BorderRadius.all(Radius.circular(2.0))),
          child: Row(
            children: <Widget>[
              recording.playCount == 0 ?
              Container() : _buildChips(
                  Icon(
                    Icons.play_arrow,
                    color: Colors.white,
                    size: 14.0,
                  ),
                  '${recording.playCount}'),
              recording.upvoteCount == 0 ?
              Container() : _buildChips(
                  Icon(
                    Icons.favorite,
                    color: Colors.white,
                    size: 14.0,
                  ),
                  '${recording.upvoteCount}')
            ],
          ),
        );

        Widget _buildGenreChip(String genre) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 2.0),
              child: Container(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    genre,
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontSize: 12.0),
                  ),
                ),
                decoration: BoxDecoration(
                    color: Colors.lightGreen,
                    borderRadius: BorderRadius.circular(16.0)),
              ),
            );

        final _subtitle = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(bottom: 4.0),
              child: Text(
                recording.description,
              ),
            ),
            recording.genre.length == 0
                ? Container()
                : Container(
                    height: 30.0,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: recording.genre
                          .map((genre) => _buildGenreChip(genre))
                          .toList(),
                    ),
                  )
          ],
        );

        final _titleSection = Padding(
          padding: const EdgeInsets.only(
            bottom: 4.0,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[Text(recording.title), _playLikeSection],
          ),
        );

        _openRecording() => Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => PlayerPage(
                      recording: recording,
                      recordings: _recordings,
                    ),
                fullscreenDialog: true) //_handlePlayRecording(),
            );
        return Column(
          children: <Widget>[
            ListTile(
              leading: _buildLeadingSection(model),
              title: _titleSection,
              subtitle: _subtitle,
              trailing: _buildPopUpMenu(model),
              onTap: () => _openRecording(),
            ),
            Divider()
          ],
        );
      },
    );
  }
}

// enum RecordingActions { share, open, bookmark, upvote }
