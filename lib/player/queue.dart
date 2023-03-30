import 'package:audio_service/audio_service.dart';
import 'package:flutter/material.dart';

import 'state.dart';

class PlayerQueueWidget extends StatelessWidget {
  final Stream<QueueState> stream;
  final BaseAudioHandler handler;

  const PlayerQueueWidget(
      {Key? key, required this.stream, required this.handler})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QueueState>(
        stream: stream,
        builder: (context, snapshot) {
          if (snapshot.data == null) return Container();
          return ListView(
            shrinkWrap: true,
            children: [
              for (var i = 0; i < snapshot.data!.queue.length; i++)
                ListTile(
                  leading: Image.network(
                      snapshot.data!.queue[i].artUri?.toString() ?? ''),
                  title: Text(snapshot.data!.queue[i].title),
                  subtitle: Text(snapshot.data!.queue[i].artist ?? ''),
                  onTap: () => handler.skipToQueueItem(i),
                  selected: snapshot.data!.mediaItem?.id ==
                      snapshot.data!.queue[i].id,
                  onLongPress: () => showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Remove audio'),
                      content: Text(
                          'Are you sure you want to remove ${snapshot.data!.queue[i].title} from the list?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          child: const Text('CANCEL'),
                        ),
                        TextButton(
                          onPressed: () {
                            if (snapshot.data!.mediaItem?.id ==
                                snapshot.data!.queue[i].id) {
                              handler.stop();
                              if (handler.queue.value.length == 1) {
                                handler.mediaItem.add(null);
                              } else {
                                handler.skipToNext();
                              }
                            }
                            handler.removeQueueItem(snapshot.data!.queue[i]);
                            Navigator.of(context).pop();
                          },
                          child: const Text('REMOVE'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          );
        });
  }
}
