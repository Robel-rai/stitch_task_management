import 'package:csv/csv.dart'; void main() { print(CsvCodec().decoder.convert('a,b\n1,2')); }
