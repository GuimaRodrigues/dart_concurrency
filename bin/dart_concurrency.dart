import 'dart:isolate';
import 'dart:math';

void main(List<String> arguments) async {
  // Criando variaveis
  int tamanhoMatriz = 10, linhas = 5;

  List<num> novaMatrixParalelo =
      List.generate(linhas, (index) => 0, growable: true);

  List<int> novaMatrixSequencial =
      List.generate(linhas, (index) => 0, growable: true);
  dynamic matrix1 = generateMatrix(linhas, tamanhoMatriz);

  List<int> matrix2 = [];
  for (int i = 0; i < tamanhoMatriz; i++) {
    matrix2.add(Random().nextInt(50));
  }
  print("Matriz original $matrix1");
  print("");
  print("Matriz que vai multiplicar a matriz original $matrix2");
  print("");

  ToyExemplo toyExemplo = ToyExemplo();

  // Execução trecho sequencial
  Stopwatch tempoSequencial = Stopwatch()..start();
  await toyExemplo.multiplicaMatrizSequencial(
      novaMatrixSequencial, matrix1, matrix2);
  print('Tempo de execução sequencial ${tempoSequencial.elapsed}');
  print("");

  // Execução trecho sequencial
  Stopwatch tempoParalelo = Stopwatch()..start();
  await toyExemplo.multiplicaMatrizParalelo(
      novaMatrixParalelo, matrix1, matrix2);
  print('Tempo de execução paralela ${tempoParalelo.elapsed}');
  print("");

  print("Resultado Final $novaMatrixParalelo");
}

generateMatrix(int rows, int cols) {
  // Criar matriz com valores dinamicos
  List<List<int>> matrix = [];

  for (int i = 0; i < rows; i++) {
    matrix.add([]);
    for (int j = 0; j < cols; j++) {
      matrix[i].add(Random().nextInt(50));
    }
  }

  return matrix;
}

class ToyExemplo {
  multiplicaMatrizParalelo(novaMatrixParalelo, matrix1, matrix2) async {
    dynamic retorno;
    for (int i = 0; i < novaMatrixParalelo.length; i++) {
      var isolateListener = ReceivePort();
      retorno = isolateListener.first;
      var port = ReceivePort();
      Isolate.spawn(_logicaToy, port.sendPort);
      SendPort portNewIsolate = await port.first;

      portNewIsolate.send(
        {
          'isolate': isolateListener.sendPort,
          'matrix1': matrix1[i],
          'matrix2': matrix2,
          'novaMatrix': novaMatrixParalelo,
          'posicaoMatriz': i,
        },
      );
      novaMatrixParalelo[i] = await retorno;
    }
  }

  multiplicaMatrizSequencial(novaMatrixSequencial, matrix1, matrix2) async {
    int tamanhoMatriz1 = matrix1.length;
    for (int j = 0; j < tamanhoMatriz1; j++) {
      for (int k = 0; k < matrix1.length; k++) {
        var row = matrix1[k];
        num soma = 0;

        for (int i = 0; i < matrix2.length; i++) {
          soma = soma + row[i] * matrix2[i];
          if (j <= row.length - 1) {
            novaMatrixSequencial[k] = soma;
          }
        }
      }
    }
    print("Matriz sequencial $novaMatrixSequencial");
    print("");
    return novaMatrixSequencial;
  }
}

_logicaToy(SendPort message) {
  var isolatePrivatePort = ReceivePort();
  message.send(isolatePrivatePort.sendPort);
  isolatePrivatePort.listen((message) {
    var externalIsolate = message['isolate'];
    List<int> matrix1 = message['matrix1'];
    List<int> matrix2 = message['matrix2'];
    List<num> novaMatrix = message['novaMatrix'];
    int posicaoMatriz = message['posicaoMatriz'];
    externalIsolate.send(_multiplicaMatriz(
        externalIsolate, posicaoMatriz, novaMatrix, matrix1, matrix2));
  });
}

_multiplicaMatriz(
    externalIsolate, posicaoMatriz, novaMatrix, matrix1, matrix2) {
  int tamanhoMatriz1 = novaMatrix.length;
  for (int j = 0; j < tamanhoMatriz1; j++) {
    num soma = 0;

    for (int i = 0; i < matrix2.length; i++) {
      soma = soma + matrix1[i] * matrix2[i];
      if (j <= matrix1.length - 1) {
        novaMatrix[j] = soma;
      }
    }
  }

  print(
      "Isolate $posicaoMatriz  e nova parte de matriz ${novaMatrix[posicaoMatriz]}");
  print("");

  return novaMatrix[posicaoMatriz];
}
