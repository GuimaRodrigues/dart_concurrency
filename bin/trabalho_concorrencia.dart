import 'dart:isolate';

void main(List<String> arguments) async {
  List<int> novaMatrix = [0, 0, 0];
  dynamic matrix1 = [
    [1, 2, 3, 4],
    [5, 6, 7, 8],
    [4, 3, 2, 1]
  ];

  dynamic matrix2 = [11, 12, 13, 14];
  print("Matriz original $matrix1");
  print("Matriz que vai multiplicar a matriz original $matrix2");
  ToyExemplo toyExemplo = ToyExemplo();
  await toyExemplo.multiplicaMatriz(novaMatrix, matrix1, matrix2);

  print("Resultado Final $novaMatrix");
}

class ToyExemplo {
  dynamic matrix2 = [11, 12, 13, 14];

  multiplicaMatriz(novaMatrix, matrix1, matrix2) async {
    dynamic retorno;
    for (int i = 0; i < matrix1.length; i++) {
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
          'novaMatrix': novaMatrix,
          'posicaoMatriz': i,
        },
      );
      novaMatrix[i] = await retorno;
    }

    return await retorno;
  }

  _logicaToy(SendPort message) {
    var isolatePrivatePort = ReceivePort();
    message.send(isolatePrivatePort.sendPort);

    isolatePrivatePort.listen((message) {
      var externalIsolate = message['isolate'];
      List<int> matrix1 = message['matrix1'];
      List<int> matrix2 = message['matrix2'];
      List<int> novaMatrix = message['novaMatrix'];
      int posicaoMatriz = message['posicaoMatriz'];
      externalIsolate
          .send(_multiplicaMatriz(posicaoMatriz, novaMatrix, matrix1, matrix2));
    });
  }

  _multiplicaMatriz(posicaoMatriz, novaMatrix, matrix1, matrix2) {
    int tamanhoMatriz1 = matrix1.length;
    for (int j = 0; j < tamanhoMatriz1; j++) {
      num soma = 0;

      for (int i = 0; i < tamanhoMatriz1; i++) {
        soma = soma + matrix1[i] * matrix2[i];
        if (j < matrix1.length - 1) {
          novaMatrix[j] = soma;
        }
      }
    }
    return novaMatrix[posicaoMatriz];
  }
}
