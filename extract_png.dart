import 'dart:io';
import 'dart:convert';

void main() async {
  final file = File(r'c:\Users\yared\Documents\Project\AntiGravity Projects\Task Man 3\stitch_task_management\AppLogo\Task Flow.svg');
  final content = await file.readAsString();
  
  final regex = RegExp(r'data:image/png;base64,([^"]+)');
  final match = regex.firstMatch(content);
  
  if (match != null) {
    final base64Str = match.group(1)!;
    final bytes = base64Decode(base64Str);
    
    final outFile = File(r'c:\Users\yared\Documents\Project\AntiGravity Projects\Task Man 3\stitch_task_management\AppLogo\Task Flow.png');
    await outFile.writeAsBytes(bytes);
    print('Successfully extracted PNG to AppLogo\\Task Flow.png');
  } else {
    print('Failed to find base64 image in SVG');
  }
}
