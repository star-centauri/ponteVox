unit ponteProcessa;

interface
uses
    dvcrt,
    dvwin,
    dvform,
    sysutils,
    classes,
    pontemsg,
    pontevars,
    ponteconfig;

procedure processa;

implementation

{--------------------------------------------------------}
{ Gera um form padrão a parti de uma ponte(nova ou não)  }
{--------------------------------------------------------}
procedure criarFormPonte(out ponte: UserPonte);
const
    tipoponte :  string = 'WEB|FTP|DROPBOX';
begin
    formCria;

    formCampo      ('PTNOME',     'Nome',                                            ponte.Nome,     50);
    formCampolista ('PTTIPO',     'Tipo (F9 Ajuda)',                                 ponte.Tipo,     10, tipoponte);
    formcampo      ('PTSERVIDOR', 'Servidor',                                        ponte.Servidor, 50);
    formcampoint   ('PTPORTA',    'Porta',                                           ponte.Porta);
    formCampoBool  ('',           'Autenticação automática? (somente para DROPBOX)', ponte.Auth);
    formcampo      ('PTCONTA',    'Conta',                                           ponte.Conta,    20);
    formcampo      ('PTSENHA',    'Senha',                                           ponte.Senha,    15);
    formEdita(true);
end;

{--------------------------------------------------------}
{        Gravar os dados da ponte no pontes.ini          }
{--------------------------------------------------------}
procedure gravarPonteSintAmbiente(ponte: UserPonte);
var
    senha: string;
begin
    senha := aplicaSenha(ponte.Senha);
    {inserindo no arquivo ini}
    sintGravaAmbienteArq(ponte.Nome, 'Nome',     ponte.Nome,            arqIniPontes);
    sintGravaAmbienteArq(ponte.Nome, 'Tipo',     ponte.Tipo,            arqIniPontes);
    sintGravaAmbienteArq(ponte.Nome, 'Servidor', ponte.Servidor,        arqIniPontes);
    sintGravaAmbienteArq(ponte.Nome, 'Porta',    intTostr(ponte.Porta), arqIniPontes);
    sintGravaAmbienteArq(ponte.Nome, 'Conta',    ponte.Conta,           arqIniPontes);
    sintGravaAmbienteArq(ponte.Nome, 'Senha',    senha,                 arqIniPontes);
    sintGravaAmbienteArq(ponte.Nome, 'Auth',     BoolToStr(ponte.Auth), arqIniPontes);
end;

{--------------------------------------------------------}
{                        Validação                       }
{--------------------------------------------------------}
function validacao (nome: shortstring): boolean;
var
    spontes: TstringList;
    i : integer;
    aux : boolean;

begin
    spontes := sintItensAmbienteArq('', arqIniPontes);

    {Percorrendo a StringList}

    aux := false;
    for i := 0 to spontes.count-1 do
    begin
        if nome = spontes[i] then
        begin
            aux := true;
            break;
        end
        else
            aux := false;
    end;

    result := aux;
    spontes.free;
end;

{--------------------------------------------------------}
{                     editar ponte                       }
{--------------------------------------------------------}
procedure editar(nomeDig: shortstring);
var
    snome: string;
    tipo, servidor, conta, senha, nome : shortstring;
    porta : integer;

begin
    clrscr;
    textBackground (BLUE);
    Writeln ('Editar Ponte: ');
    writeln;
    textBackground (BLACK);

    if nomeDig = '' then
        begin
            mensagem ('PTDIGITEL', 0); // digite a ponte a listar
            sintreadln(snome);

            if snome = '' then
                exit;
        end
    else
        snome := nomeDig;

    writeln;
    {recebendo valores}
    nome := sintambientearq(snome, 'Nome', 'Não registrado', arqIniPontes);
    tipo := sintambientearq(snome, 'Tipo', 'Não registrado', arqIniPontes);
    servidor := sintambientearq(snome, 'Servidor', 'Não registrado', arqIniPontes);
    porta := strtoint(sintambientearq(snome, 'Porta', 'Não registrado', arqIniPontes));
    conta := sintambientearq(snome, 'Conta', 'Não registrado', arqIniPontes);
    senha := sintambientearq(snome, 'Senha', 'Não registrado', arqIniPontes);
    {valores recebidos}
    senha := aplicaSenha(senha);

    {imprimindo valores recebidos}
    clrscr;
    textBackground (BLUE);
    Writeln ('Listar Ponte: ');
    writeln;

    {formulario de exibicao de  ponte}

    formCria;
    formCampo('', 'Nome', nome, 50);
    formcampo('', 'Tipo', tipo, 20);
    formcampo('', 'Servidor', servidor, 50);
    formcampoint('', 'Porta', porta);
    formcampo('', 'Conta', conta, 100);
    formcampo('', 'Senha', senha, 15);
    formEdita(true);

    {fim do formulario}

    if nome<>'' then
    begin
        senha := aplicaSenha(senha);

        {inserindo no arquivo ini}
        sintGravaAmbienteArq(nome,'Nome', nome, arqIniPontes);
        sintGravaAmbienteArq(nome, 'Tipo', UpperCase(tipo), arqIniPontes);
        sintGravaAmbienteArq(nome, 'Servidor', servidor, arqIniPontes);
        sintGravaAmbienteArq(nome, 'Porta', intTostr(porta), arqIniPontes);
        sintGravaAmbienteArq(nome, 'Conta', conta, arqIniPontes);
        sintGravaAmbienteArq(nome, 'Senha', senha, arqIniPontes);

        {fim da inserção}
        writeln;
        mensagem ('PTPONTE', 0); // a ponte
        sintwrite(nome);
        mensagem('PTPONTEI', 0); // foi inserida com sucesso
    end
    else
    begin
        textBackground (MAGENTA);
        writeln;
        mensagem ('PTBRANCO', 1);  //'Nome em branco.  Registro ignorado'
        textBackground (BLACK);
        delay (2000);
        exit;
    end;

end;


{--------------------------------------------------------}
{                         listar ponte                   }
{--------------------------------------------------------}
procedure listar;
var
    snome: string;
    nome, tipo, servidor, conta, senha : shortstring;
    porta : integer;

begin
    clrscr;
    textBackground (BLUE);
    Writeln ('Listar Ponte: ');
    writeln;
    textBackground (BLACK);

    mensagem ('PTDIGITEL', 0); // digite a ponte a listar
    sintreadln(snome);

    if snome = '' then
        exit;

    writeln;
    {recebendo valores}

    nome := sintambientearq(snome, 'Nome', 'Não registrado', arqIniPontes);
    tipo := sintambientearq(snome, 'Tipo', 'Não registrado', arqIniPontes);
    servidor := sintambientearq(snome, 'Servidor', 'Não registrado', arqIniPontes);
    porta := strtoint(sintambientearq(snome, 'Porta', 'Não registrado', arqIniPontes));
    conta := sintambientearq(snome, 'Conta', 'Não registrado', arqIniPontes);
    senha := sintambientearq(snome, 'Senha', 'Não registrado', arqIniPontes);
    {valores recebidos}

    if nome <> 'Não registrado' then
    begin
        {imprimindo valores recebidos}
        clrscr;
        textBackground (BLUE);
        Writeln ('Listar Ponte: ');
        writeln;
        textBackground (BLACK);

        senha := aplicaSenha(senha);

        {formulario de exibicao de  ponte}
        formCria;
        formCampo('', 'Nome', nome,50);
        formCampo('', 'Tipo', tipo,3);
        formCampo('', 'Servidor', servidor, 50);
        formCampoint('', 'Porta', porta);
        formCampo('', 'Conta', conta,20);
        formcampo('', 'Senha', senha,15);
        formEdita(false);

        {fim do formulario}

    end;

    if nome = 'Não registrado' then
    begin
        clrscr;
        mensagem ('PTNREGIST', 1); // ponte não registrada
        delay(2000)
    end;

    clrscr;
end;

{--------------------------------------------------------}
{                       remover ponte                    }
{--------------------------------------------------------}
procedure remover;
var
    nome : string;

begin
    clrscr;
    textBackground (BLUE);
    Writeln ('Remover Ponte: ');
    writeln;
    textBackground (BLACK);

    mensagem ('PTDIGITE', 0); //digite o nome da ponte a ser removida
    sintreadln(nome);

    if nome = '' then exit;

    sintremoveambientearq(nome, '', arqIniPontes);

    clrscr;
    textBackground (BLUE);
    Writeln ('Remover Ponte: ');
    writeln;
    textBackground (BLACK);
    mensagem ('PTSUCESSO', 0); //ponte removida com sucesso
    delay(2000);
    clrscr;
end;

{--------------------------------------------------------}
{                     mostra uma Ponte                   }
{--------------------------------------------------------}
function mostraumaPonte (n: integer; sl: TStringList): char;
var
    nome, tipo, servidor, conta, senha : shortstring;
    porta : integer;
    snome : string;

begin
    if n < 1 then
        begin
           sintBip;
           result := #81;
           exit;
        end;

    if n > sl.count then
        begin
           sintBip;
           result := #73;
           exit;
        end;

    snome:=sl[n-1];

    nome := sintambientearq(snome, 'Nome', 'Não registrado', arqIniPontes);
    tipo := sintambientearq(snome, 'Tipo', 'Não registrado', arqIniPontes);
    servidor := sintambientearq(snome, 'Servidor', 'Não registrado', arqIniPontes);
    porta := strtoint(sintambientearq(snome, 'Porta', 'Não registrado', arqIniPontes));
    conta := sintambientearq(snome, 'Conta', 'Não registrado', arqIniPontes);
    senha := sintambientearq(snome, 'Senha', 'Não registrado', arqIniPontes);

    {valores recebidos}
    if nome <> 'Não registrado' then
    begin
         {imprimindo valores recebidos}
         clrscr;
         textBackground (BLUE);
         Writeln ('Listar Ponte: ');
         writeln;
         textBackground (BLACK);

         senha := aplicaSenha(senha);

         {formulario de exibicao de ponte}
         formCria;
         formCampo('', 'Nome', nome,50);
         formcampo('', 'Tipo', tipo,3);
         formcampo('', 'Servidor', servidor, 50);
         formcampoint('', 'Porta', porta);
         formcampo('', 'Conta', conta,20);
         formcampo('', 'Senha', senha,15);

         mostraumaPonte := formEdita(false);   // o retorno é um caractere que termina o formulário

        {fim do formulario}

    end
    else
        begin
            mensagem ('PTNREG', 0); // não registrado
            delay(2000);
            result := esc;
        end;
end;

{--------------------------------------------------------}
{                      folhear ponte                     }
{--------------------------------------------------------}
procedure folhear;
var sl : TStringList;
    i, n: integer;
    c: char;
    s: string;

begin
    clrscr;
    textBackground (BLUE);
    Writeln ('Folhear Pontes: ');
    writeln;
    textBackground (BLACK);

    sl := sintItensAmbienteArq ('', arqIniPontes);

    mensagem('PTENCONTRADOS', 0); //foram encontrados
    sintwrite(intToStr (sl.count));
    mensagem('PTREG', 2); // registros

    popupMenuCria (wherex, wherey, 20, sl.count, blue);
    for i := 0 to sl.count-1 do
        begin
            s := sintAmbienteArq (sl[i], 'Nome', '', arqIniPontes);
            popupmenuadiciona('', s);
        end;

    n := popupMenuSeleciona;


    if n > 0 then
    begin
      repeat
        c := mostraumaPonte(n, sl);
        if c = #73 then
            n := n - 1
        else
        if c = #81 then
            n := n + 1;
      until c = #27;

    end;
    sl.free;

end;

function verificarPonteExiste(out ponte: UserPonte) : boolean;
var
    existeNome: string;
begin
    existeNome := sintambientearq(ponte.Nome, 'Nome', '', arqIniPontes);

    if existeNome <> '' then
        begin
            sintWriteLn('A ponte ' + existeNome + ' já foi criada.');
            sintWriteLn('Deseja sobrescever a anterior?');
            if popupMenuPorLetra('SN') = 'N' then
                begin
                    sintWriteLn('Infome um novo nome, ou aperte ESC para excluir ponte e voltar ao menu principal.');
                    qq();
                end
            else
                Result := true;
        end
end;

{--------------------------------------------------------}
{                     Inserir Pontes                     }
{--------------------------------------------------------}
procedure inserir;
var
    novaPonte: UserPonte;
    valida : boolean;

begin
    clrscr;
    textBackground (BLUE);
    Writeln ('Adicionar Ponte: ');
    writeln;
    textBackground (BLACK);

    {formulario de inserção de pontes}
    criarFormPonte(novaPonte);

    if novaPonte.Nome = '' then
        begin
            textBackground (BLUE);
            mensagem('PTBRANCO', 0); // nome em branco registro ignorado
            textBackground (BLACK);
            delay (2000);
            exit;
        end;

    {Validar se ponte existe}





    valida := validacao(novaPonte.Nome);

    if valida = true then
    begin
          editar(novaponte.Nome); // solicitando a procedure de edição
    end
    {fim da validação de pontes}
    else
    begin
        gravarPonteSintAmbiente(novaPonte);

        writeln;
        mensagem ('PTPONTE', 0); // a ponte
        sintwrite(novaPonte.Nome);
        mensagem('PTPONTEI', 0); // foi inserida com sucesso
        clrscr;
    end;
end;

{--------------------------------------------------------}
{           executar comando que foi solicitado          }
{--------------------------------------------------------}
procedure executarComando(option: char);
begin
    limpaBaixo (wherey);

    case upcase(option) of
        'I': inserir;  { procedure de inserção de pontes    }
        'L': listar;   { procedure de listagem de pontes    }
        //'R': remover;  { procedure de remoção de pontes    }
        //'F': folhear;  { procedure de folheamento de pontes  }
        //'E': editar('');   { procedure de edição de ponte}
    else
        textBackground (MAGENTA);
        mensagem ('PTOPCAOI', 0); //opção inválida
        textBackground (BLACK);
        clrscr;
    end;
end;

{--------------------------------------------------------}
{            seleciona a opção com as setas              }
{--------------------------------------------------------}
function selSetasOpcao: char;
var
    n: integer;
const
    tabLetrasOpcao: string = 'IL' + ESC;

begin
    garanteEspacoTela (9);
    popupMenuCria (wherex, wherey, 50, length(tabLetrasOpcao), MAGENTA);
    popupMenuAdiciona ('PTINSERIR',  'I - Inserir Ponte');
    popupMenuAdiciona ('PTLISTAR',   'L - Listar Ponte');

    popupMenuAdiciona ('PTTERMINAR', 'ESC - terminar' );

    n := popupMenuSeleciona;
    if n > 0 then
        begin
            selSetasOpcao := tabLetrasOpcao[n];
            writeln (tabLetrasOpcao[n]);
        end
    else
        selSetasOpcao := ESC;
end;

{--------------------------------------------------------}
{            seleciona a teclas de ações                 }
{--------------------------------------------------------}
procedure selecionarOpcoes(out processa: boolean);
var keypress1, keypress2: char;
    opcao: string;

begin
    opcao := '';
    sintLeTecla (keypress1, keypress2);

    if (keypress1 = #0) and ((keypress2 = CIMA) or (keypress2 = BAIX) or (keypress2 = F9)) then
        begin
            keypress1 := selSetasOpcao;
            if keypress1 <> #$1b then
                opcao := copy(opcoesItemSelecionado, pos('-', opcoesItemSelecionado)-1, 999);
        end;

    if keypress1 = ESC then
        begin
            processa := false;
            exit;
        end;

    executarComando(keypress1);
end;

{--------------------------------------------------------}
{                loop de processamento                   }
{--------------------------------------------------------}
procedure processa;
var processa: boolean;
begin
    processa := true;

    while processa do
        begin
            textBackground (BLUE);
            mensagem ('PTOPCAO', 0);   { Qual sua opção? }
            textBackground (BLACK);

            selecionarOpcoes(processa);
        end;
end;

end.
