{--------------------------------------------------------}
{                                                        }
{    Teste de fala                                       }
{                                                        }
{    Módulo de mensagens                                 }
{                                                        }
{    Autor:  José Antonio Borges                         }
{                                                        }
{    Em outubro/2015                                     }
{                                                        }
{--------------------------------------------------------}

unit pontemsg;

interface

uses
    dvcrt,
    dvWin,
    dvWav,
    windows,
    sysUtils;

function pegaTextoMensagem (nomeArq: string): string;
procedure mensagem (nomeArq: string; nlf: integer);

implementation

{--------------------------------------------------------}
{              descobre o texto da mensagem
{--------------------------------------------------------}

function pegaTextoMensagem (nomeArq: string): string;
var s: string;
begin
    if nomeArq = 'PTINIC' then
        s := 'Pontevox Versão '
    else
    if nomeArq = 'PTFIM' then
        s := 'Fim do programa.'
    else
    if nomeArq = 'PTBRANCO' then
        s := 'Nome em branco, registro ignorado.'
    else
    if nomeArq = 'PTDIGITE' then
        s:= 'Digite o nome da ponte a ser removida: '
    else
    if nomeArq = 'PTDIGITEL' then
        s := 'Digite o nome da ponte a ser listada: '
    else
    if nomeArq = 'PTENCONTRADOS' then
        s:= 'Foram encontrados '
    else
    if nomeArq = 'PTFOLHEAR' then
        s:= 'F - Folhear pontes'
    else
    if nomeArq ='PTFOLHEARP' then
    s:= 'Folhear pontes'
    else
    if nomeArq =  'PTINSERIR' then
        s:='I - Inserir'
    else
    if nomeArq = 'PTLISTAR' then
        s:='L - Listar ponte'
    else
    if nomeArq = 'PTLISTARP' then
        s := 'Listar ponte'
    else
    if nomeArq = 'PTREG' then
        s :=  ' registros'
    else
    if nomeArq = 'PTREGIST' then
        s := 'Ponte não registrada'
    else
    if nomeArq = 'PTOPCAO' then
        s:= 'As opções são: '
    else
    if nomeArq = 'PTOPCAOI' then
        s:=   'Opção inválida'
    else
   if nomeArq = 'PTPONTE' then
        s:=   'A ponte '
    else
    if nomeArq = 'PTPONTEI' then
        s := ' foi inserida com sucesso.'
    else
    if nomeArq = 'PTQOPCAO' then
        s := 'Qual sua opção?'
    else
    if nomeArq = 'PTREMOVEP' then
        S := 'Remover ponte'
    else
    if nomeArq = 'PTREMOVER' then
        s:= 'R - Remover ponte'
    else
    if nomeArq= 'PTSUCESSO' then
        s:='Removida com sucesso!'
    else
    if nomeArq = 'PTTERMINAR' then
        s := 'ESC - Terminar'
    else
    if nomeArq = 'FLNIMPL' then
        s := 'Não implementado.'
    else
        s := '--> Mensagem inválida: ' + nomeArq;

   pegaTextoMensagem := s;
end;

{--------------------------------------------------------}
{                    dá uma mensagem
{--------------------------------------------------------}

procedure mensagem (nomeArq: string; nlf: integer);
var i: integer;
    s: string;
begin
    s := pegaTextoMensagem (nomeArq);

    if nlf >= 0 then write (s);
    for i := 1 to nlf do
         writeln;

    if existeArqSom ('EF_' + nomeArq) then
        sintSom ('EF_' + nomeArq);

    if existeArqSom (nomeArq) then
        sintSom (nomeArq)
    else
        sintetiza (s);
end;

end.
