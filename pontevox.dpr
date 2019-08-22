{--------------------------------------------------------}
{                                                        }
{    Programa: PonteVox                                  }
{                                                        }
{    Módulo de Controle das pontes do Dosvox             }
{                                                        }
{    Autores: João Marcelo & João Pedro & Bruna de Lima  }
{                                                        }
{    Em julho/2018                                       }
{    Em julho/2019                                       }
{                                                        }
{--------------------------------------------------------}

program pontevox;

uses
  windows,
  dvcrt,
  dvwin,
  dvform,
  sysutils,
  classes,
  pontemsg,
  ponteProcessa,
  pontevars;

{--------------------------------------------------------}
{                 Inicializa PONTEVOX                    }
{--------------------------------------------------------}
procedure inicializa;
var
    ambiente: string;
{----------------BEGIN Inicializa Ambiente---------------}
    procedure inicializaSintAmbiente;
        begin
            setWindowTitle('PONTEVOX');{ nome do programa }

            ambiente := sintAmbiente('PONTEVOX', 'DIRPONTEVOX');
            if ambiente = '' then
                ambiente := sintAmbiente('DOSVOX', 'PGMDOSVOX') + '\som\PonteVox';

            arqIniPontes := sintAmbiente('PONTEVOX', 'ARQPONTES');
            if arqIniPontes = '' then
                arqIniPontes := sintDirAmbiente + '\pontes.ini';
            if not fileExists (arqIniPontes) then
                arqIniPontes := '.\pontes.ini';

            sintinic (0, ambiente);
        end;
{----------------END Inicializa Ambiente---------------}
begin
    clrscr;
    inicializaSintAmbiente;

    textBackground (BLUE);
    mensagem('PTINIC', 0);
    sintWriteln(versao);
    textBackground (Black);
    Writeln;
end;

{--------------------------------------------------------}
{                     fecha o programa                   }
{--------------------------------------------------------}
procedure termina;
begin
    mensagem('PTFIM', 0); // fim do programa
    sintfim;
    doneWinCrt;
end;

{--------------------------------------------------------}
{                   programa principal                   }
{--------------------------------------------------------}
begin
    inicializa;
    processa;
    termina;
end.
