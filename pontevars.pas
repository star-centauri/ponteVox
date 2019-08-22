unit pontevars;

interface
const
    versao = '2.1';

var
    arqIniPontes: string;

type
    UserPonte = record
        Nome     : shortstring;
        Tipo     : shortstring;
        Servidor : shortstring;
        Porta    : integer;
        Conta    : shortstring;
        Senha    : shortstring;
        Auth     : boolean;
    end;

implementation

end.
