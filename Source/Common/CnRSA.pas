{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     中国人自己的开放源码第三方开发包                         }
{                   (C)Copyright 2001-2018 CnPack 开发组                       }
{                   ------------------------------------                       }
{                                                                              }
{            本开发包是开源的自由软件，您可以遵照 CnPack 的发布协议来修        }
{        改和重新发布这一程序。                                                }
{                                                                              }
{            发布这一开发包的目的是希望它有用，但没有任何担保。甚至没有        }
{        适合特定目的而隐含的担保。更详细的情况请参阅 CnPack 发布协议。        }
{                                                                              }
{            您应该已经和开发包一起收到一份 CnPack 发布协议的副本。如果        }
{        还没有，可访问我们的网站：                                            }
{                                                                              }
{            网站地址：http://www.cnpack.org                                   }
{            电子邮件：master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnRSA;
{* |<PRE>
================================================================================
* 软件名称：开发包基础库
* 单元名称：RSA 算法单元
* 单元作者：刘啸
* 备    注：包括 Int64 范围内的 RSA 算法以及大数算法，公钥 Exponent 固定使用 65537。
* 开发平台：WinXP + Delphi 5.0
* 兼容测试：暂未进行
* 本 地 化：该单元无需本地化处理
* 修改记录：2018.05.27 V1.3
*               能够从 Openssl 生成的未加密的公私钥 PEM 格式文件中读入公私钥，如
*               openssl genrsa -out private.pem 2048
*                  // PKCS#1 格式的公私钥
*               openssl pkcs8 -topk8 -inform PEM -in private.pem -outform PEM -nocrypt -out private_pkcs8.pem
*                  // PKCS#8 格式的公私钥
*               openssl rsa -in private.pem -outform PEM -pubout -out public.pem
*                  // PKCS#8 格式的公钥
*           2018.05.22 V1.2
*               将公私钥组合成对象以方便使用
*           2017.04.05 V1.1
*               实现大数的 RSA 密钥生成与加解密
*           2017.04.03 V1.0
*               创建单元，Int64 范围内的 RSA 从 CnPrimeNumber 中独立出来
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Windows, CnPrimeNumber, CnBigNumber, CnBase64, CnBerParser;

type
  TCnRSAPrivateKey = class
  private
    FPrimeKey1: TCnBigNumber;
    FPrimeKey2: TCnBigNumber;
    FPrivKeyProduct: TCnBigNumber;
    FPrivKeyExponent: TCnBigNumber;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;

    property PrimeKey1: TCnBigNumber read FPrimeKey1 write FPrimeKey1;
    {* 大素数 1，p}
    property PrimeKey2: TCnBigNumber read FPrimeKey2 write FPrimeKey2;
    {* 大素数 2，q}
    property PrivKeyProduct: TCnBigNumber read FPrivKeyProduct write FPrivKeyProduct;
    {* 俩素数乘积 n，也叫 Modulus}
    property PrivKeyExponent: TCnBigNumber read FPrivKeyExponent write FPrivKeyProduct;
    {* 私钥指数 d}
  end;

  TCnRSAPublicKey = class
  private
    FPubKeyProduct: TCnBigNumber;
    FPubKeyExponent: TCnBigNumber;
  public
    constructor Create;
    destructor Destroy; override;
    procedure Clear;

    property PubKeyProduct: TCnBigNumber read FPubKeyProduct write FPubKeyProduct;
    {* 俩素数乘积 n，也叫 Modulus}
    property PubKeyExponent: TCnBigNumber read FPubKeyExponent write FPubKeyExponent;
    {* 公钥指数 e，65537}
  end;

// Int64 范围内的 RSA 加解密实现

// function Int64ExtendedEuclideanGcd(A, B: Int64; out X: Int64; out Y: Int64): Int64;
{* 扩展欧几里得辗转相除法求二元一次不定方程 A * X + B * Y = 1 的整数解}

function CnInt64RSAGenerateKeys(out PrimeKey1: Integer; out PrimeKey2: Integer;
  out PrivKeyProduct: Int64; out PrivKeyExponent: Int64;
  out PubKeyProduct: Int64; out PubKeyExponent: Int64): Boolean;
{* 生成 RSA 算法所需的公私钥，素数均不大于 Integer，Keys 均不大于 Int64}

function CnInt64RSAEncrypt(Data: Int64; PrivKeyProduct: Int64;
  PrivKeyExponent: Int64; out Res: Int64): Boolean;
{* 利用上面生成的私钥对数据进行加密，返回加密是否成功}

function CnInt64RSADecrypt(Res: Int64; PubKeyProduct: Int64;
  PubKeyExponent: Int64; out Data: Int64): Boolean;
{* 利用上面生成的公钥对数据进行解密，返回解密是否成功}

// 大数范围内的 RSA 加解密实现

function CnRSAGenerateKeys(Bits: Integer; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey): Boolean;
{* 生成 RSA 算法所需的公私钥，Bits 是素数范围，其余参数均为生成}

function CnRSALoadKeysFromPem(const PemFileName: string;
  PrivateKey: TCnRSAPrivateKey; PublicKey: TCnRSAPublicKey): Boolean;
{* 从 PEM 格式文件中加载公私钥数据，如某钥参数为空则不载入}

procedure CnRSASaveKeysToPem(const PemFileName: string;
  PrivateKey: TCnRSAPrivateKey; PublicKey: TCnRSAPublicKey);
{* 将公私钥写入 PEM 格式文件中}

function CnRSALoadPublicKeyFromPem(const PemFileName: string;
  PublicKey: TCnRSAPublicKey): Boolean;
{* 从 PEM 格式文件中加载公钥数据，返回是否成功}

procedure CnRSASavePublicKeyToPem(const PemFileName: string;
  PublicKey: TCnRSAPublicKey);
{* 将公钥写入 PEM 格式文件中}

function CnRSAEncrypt(Data: TCnBigNumber; PrivateKey: TCnRSAPrivateKey;
  Res: TCnBigNumber): Boolean;
{* 利用上面生成的私钥对数据进行加密，返回加密是否成功}

function CnRSADecrypt(Res: TCnBigNumber; PublicKey: TCnRSAPublicKey;
  Data: TCnBigNumber): Boolean;
{* 利用上面生成的公钥对数据进行解密，返回解密是否成功}

implementation

const
  // PKCS#1
  PEM_RSA_PRIVATE_HEAD = '-----BEGIN RSA PRIVATE KEY-----';  // 已解析
  PEM_RSA_PRIVATE_TAIL = '-----END RSA PRIVATE KEY-----';

  PEM_RSA_PUBLIC_HEAD = '-----BEGIN RSA PUBLIC KEY-----';    // 已解析
  PEM_RSA_PUBLIC_TAIL = '-----END RSA PUBLIC KEY-----';

  // PKCS#8
  PEM_PRIVATE_HEAD = '-----BEGIN PRIVATE KEY-----';          // 已解析
  PEM_PRIVATE_TAIL = '-----END PRIVATE KEY-----';

  PEM_PUBLIC_HEAD = '-----BEGIN PUBLIC KEY-----';            // 已解析
  PEM_PUBLIC_TAIL = '-----END PUBLIC KEY-----';

// 利用公私钥对数据进行加解密，注意加解密使用的是同一套机制，无需区分
function Int64RSACrypt(Data: Int64; Product: Int64; Exponent: Int64;
  out Res: Int64): Boolean;
begin
  Res := MontgomeryPowerMod(Data, Exponent, Product);
  Result := True;
end;

// 扩展欧几里得辗转相除法求二元一次不定方程 A * X + B * Y = 1 的整数解
function Int64ExtendedEuclideanGcd(A, B: Int64; out X: Int64; out Y: Int64): Int64;
var
  R, T: Int64;
begin
  if B = 0 then
  begin
    X := 1;
    Y := 0;
    Result := A;
  end
  else
  begin
    R := Int64ExtendedEuclideanGcd(B, A mod B, X, Y);
    T := X;
    X := Y;
    Y := T - (A div B) * Y;
    Result := R;
  end;
end;

// 生成 RSA 算法所需的公私钥，素数均不大于 Integer，Keys 均不大于 Int64
function CnInt64RSAGenerateKeys(out PrimeKey1: Integer; out PrimeKey2: Integer;
  out PrivKeyProduct: Int64; out PrivKeyExponent: Int64;
  out PubKeyProduct: Int64; out PubKeyExponent: Int64): Boolean;
var
  N: Integer;
  Product, Y: Int64;
begin
  PrimeKey1 := CnGenerateInt32Prime;

  N := Trunc(Random * 1000);
  Sleep(N);

  PrimeKey2 := CnGenerateInt32Prime;
  PrivKeyProduct := Int64(PrimeKey1) * Int64(PrimeKey2);
  PubKeyProduct := Int64(PrimeKey2) * Int64(PrimeKey1);   // 积在公私钥中是相同的
  PubKeyExponent := 65537;                                // 固定

  Product := Int64(PrimeKey1 - 1) * Int64(PrimeKey2 - 1);

  //                      e                d                p
  // 用辗转相除法求 PubKeyExponent * PrivKeyExponent mod Product = 1 中的 PrivKeyExponent
  // 也就是解方程 e * d + p * y = 1，其中 e、p 已知，求 d 与 y。
  Int64ExtendedEuclideanGcd(PubKeyExponent, Product, PrivKeyExponent, Y);
  while PrivKeyExponent < 0 do
  begin
     // 如果求出来的 d 小于 0，则不符合条件，需要将 d 加上 p，加到大于零为止
     PrivKeyExponent := PrivKeyExponent + Product;
  end;
  Result := True;
end;

// 利用上面生成的私钥对数据进行加密，返回加密是否成功
function CnInt64RSAEncrypt(Data: Int64; PrivKeyProduct: Int64;
  PrivKeyExponent: Int64; out Res: Int64): Boolean;
begin
  Result := Int64RSACrypt(Data, PrivKeyProduct, PrivKeyExponent, Res);
end;

// 利用上面生成的公钥对数据进行解密，返回解密是否成功
function CnInt64RSADecrypt(Res: Int64; PubKeyProduct: Int64;
  PubKeyExponent: Int64; out Data: Int64): Boolean;
begin
  Result := Int64RSACrypt(Res, PubKeyProduct, PubKeyExponent, Data);
end;

function CnRSAGenerateKeys(Bits: Integer; PrivateKey: TCnRSAPrivateKey;
  PublicKey: TCnRSAPublicKey): Boolean;
var
  N: Integer;
  P, Y, R, S1, S2, One: TCnBigNumber;
begin
  Result := False;
  if Bits <= 16 then
    Exit;

  PrivateKey.Clear;
  PublicKey.Clear;

  if not BigNumberGeneratePrime(PrivateKey.PrimeKey1, Bits div 8) then
    Exit;

  N := Trunc(Random * 1000);
  Sleep(N);

  if not BigNumberGeneratePrime(PrivateKey.PrimeKey2, Bits div 8) then
    Exit;

  if not BigNumberMul(PrivateKey.PrivKeyProduct, PrivateKey.PrimeKey1, PrivateKey.PrimeKey2) then
    Exit;

  if not BigNumberMul(PublicKey.PubKeyProduct, PrivateKey.PrimeKey1, PrivateKey.PrimeKey2) then
    Exit;

  PublicKey.PubKeyExponent.SetDec('65537');

  R := nil;
  Y := nil;
  P := nil;
  S1 := nil;
  S2 := nil;
  One := nil;

  try
    R := TCnBigNumber.Create;
    Y := TCnBigNumber.Create;
    P := TCnBigNumber.Create;
    S1 := TCnBigNumber.Create;
    S2 := TCnBigNumber.Create;
    One := TCnBigNumber.Create;

    BigNumberSetOne(One);
    BigNumberSub(S1, PrivateKey.PrimeKey1, One);
    BigNumberSub(S2, PrivateKey.PrimeKey2, One);
    BigNumberMul(P, S1, S2);

    BigNumberExtendedEuclideanGcd(PublicKey.PubKeyExponent, P, PrivateKey.PrivKeyExponent, Y, R);

    // 如果求出来的 d 小于 0，则不符合条件，需要将 d 加上 p
    if BigNumberIsNegative(PrivateKey.PrivKeyExponent) then
       BigNumberAdd(PrivateKey.PrivKeyExponent, PrivateKey.PrivKeyExponent, P);
  finally
    One.Free;
    S2.Free;
    S1.Free;
    P.Free;
    Y.Free;
    R.Free;
  end;

  Result := True;
end;

function LoadPemFileToMemory(const FileName, ExpectHead, ExpectTail: string;
  MemoryStream: TMemoryStream): Boolean;
var
  I: Integer;
  S: string;
  Sl: TStringList;
begin
  Result := False;

  if (ExpectHead <> '') and (ExpectTail <> '') then
  begin
    Sl := TStringList.Create;
    try
      Sl.LoadFromFile(FileName);
      if Sl.Count > 2 then
      begin
        if Trim(Sl[0]) <> ExpectHead then
          Exit;

        if Trim(Sl[Sl.Count - 1]) = '' then
          Sl.Delete(Sl.Count - 1);

        if Trim(Sl[Sl.Count - 1]) <> ExpectTail then
          Exit;

        Sl.Delete(Sl.Count - 1);
        Sl.Delete(0);
        S := '';
        for I := 0 to Sl.Count - 1 do
          S := S + Sl[I];

        // To De Base64 S
        MemoryStream.Clear;
        Result := (BASE64_OK = Base64Decode(S, MemoryStream));
      end;
    finally
      Sl.Free;
    end;
  end
  else
  begin
//    MemoryStream.LoadFromFile(FileName);
//    Result := True;
  end;
end;

// 从 PEM 格式文件中加载公私钥数据
(*
PKCS#1:
  RSAPrivateKey ::= SEQUENCE {                        0
    version Version,                                  1
    modulus INTEGER, – n                             2 公私钥
    publicExponent INTEGER, – e                      3 公钥
    privateExponent INTEGER, – d                     4 私钥
    prime1 INTEGER, – p                              5 私钥
    prime2 INTEGER, – q                              6 私钥
    exponent1 INTEGER, – d mod (p-1)                 7
    exponent2 INTEGER, – d mod (q-1)                 8
    coefficient INTEGER, – (inverse of q) mod p      9
    otherPrimeInfos OtherPrimeInfos OPTIONAL          10
  }

PKCS#8:
  PrivateKeyInfo ::= SEQUENCE {
    version         Version,
    algorithm       AlgorithmIdentifier,
    PrivateKey      OCTET STRING
  }

  AlgorithmIdentifier ::= SEQUENCE {
    algorithm       OBJECT IDENTIFIER,
    parameters      ANY DEFINED BY algorithm OPTIONAL
  }
  PrivateKey 是上面 PKCS#1 的 RSAPrivateKey 结构
  也即：
  SEQUENCE(3 elem)
    INTEGER0
    SEQUENCE(2 elem)
      OBJECT IDENTIFIER 1.2.840.113549.1.1.1 rsaEncryption(PKCS #1)
      NULL
    OCTET STRING(1 elem)
      SEQUENCE(9 elem)
        INTEGER0
        INTEGER(1024 bit)                             8 公私钥 Modulus
        INTEGER                                       9 公钥   e
        INTEGER(1021 bit)                             10 私钥  d
        INTEGER(512 bit)                              11 私钥  p
        INTEGER(512 bit)                              12 私钥  q
        INTEGER(510 bit) 
        INTEGER(510 bit)
        INTEGER(511 bit)
*)
function CnRSALoadKeysFromPem(const PemFileName: string;
  PrivateKey: TCnRSAPrivateKey; PublicKey: TCnRSAPublicKey): Boolean;
var
  MemStream: TMemoryStream;
  Ber: TCnBerParser;
  Node: TCnBerNode;
  Buf: Pointer;

  procedure PutIndexedBigIntegerToBigInt(Idx: Integer; BigNumber: TCnBigNumber);
  begin
    Node := Ber.Items[Idx];
    ReallocMem(Buf, Node.BerDataLength);
    Node.CopyDataTo(Buf);
    BigNumber.SetBinary(Buf, Node.BerDataLength);
  end;

begin
  Result := False;
  MemStream := nil;
  Ber := nil;

  try
    MemStream := TMemoryStream.Create;
    if LoadPemFileToMemory(PemFileName, PEM_RSA_PRIVATE_HEAD, PEM_RSA_PRIVATE_TAIL, MemStream) then
    begin
      // 读 PKCS#1 的 PEM 公私钥格式
      Ber := TCnBerParser.Create(PByte(MemStream.Memory), MemStream.Size);
      if Ber.TotalCount >= 8 then
      begin
        Node := Ber.Items[1]; // 0 是整个 Sequence，1 是 Version
        if Node.AsByte = 0 then // 只支持版本 0
        begin
          Buf := nil;
          // 2 和 3 整成公钥
          if PublicKey <> nil then
          begin
            PutIndexedBigIntegerToBigInt(2, PublicKey.PubKeyProduct);
            PutIndexedBigIntegerToBigInt(3, PublicKey.PubKeyExponent);
          end;

          // 2 4 5 6 整成私钥
          if PrivateKey <> nil then
          begin
            PutIndexedBigIntegerToBigInt(2, PrivateKey.PrivKeyProduct);
            PutIndexedBigIntegerToBigInt(4, PrivateKey.PrivKeyExponent);
            PutIndexedBigIntegerToBigInt(5, PrivateKey.PrimeKey1);
            PutIndexedBigIntegerToBigInt(6, PrivateKey.PrimeKey2);
          end;

          ReallocMem(Buf, 0);
          Result := True;
        end;
      end;
    end
    else if LoadPemFileToMemory(PemFileName, PEM_PRIVATE_HEAD, PEM_PRIVATE_TAIL, MemStream) then
    begin
      // 读 PKCS#8 的 PEM 公私钥格式
      Ber := TCnBerParser.Create(PByte(MemStream.Memory), MemStream.Size, True);
      if Ber.TotalCount >= 12 then
      begin
        Node := Ber.Items[1]; // 0 是整个 Sequence，1 是 Version
        if Node.AsByte = 0 then // 只支持版本 0
        begin
          Buf := nil;
          // 8 和 9 整成公钥
          if PublicKey <> nil then
          begin
            PutIndexedBigIntegerToBigInt(8, PublicKey.PubKeyProduct);
            PutIndexedBigIntegerToBigInt(9, PublicKey.PubKeyExponent);
          end;
      
          // 8 10 11 12 整成私钥
          if PrivateKey <> nil then
          begin
            PutIndexedBigIntegerToBigInt(8, PrivateKey.PrivKeyProduct);
            PutIndexedBigIntegerToBigInt(10, PrivateKey.PrivKeyExponent);
            PutIndexedBigIntegerToBigInt(11, PrivateKey.PrimeKey1);
            PutIndexedBigIntegerToBigInt(12, PrivateKey.PrimeKey2);
          end;
      
          ReallocMem(Buf, 0);
          Result := True;
        end;
      end;
    end;
  finally
    MemStream.Free;
    Ber.Free;
  end;
end;

// 将公私钥写入 PEM 格式文件中
procedure CnRSASaveKeysToPem(const PemFileName: string;
  PrivateKey: TCnRSAPrivateKey; PublicKey: TCnRSAPublicKey);
begin

end;

// 从 PEM 格式文件中加载公钥数据
// 注意 PKCS#8 的 PublicKey 的 PEM 在标准 ASN.1 上做了一层封装，
// 把 Modulus 与 Exponent 封在了 BitString 中，需要 Paser 解析出来
(*
PKCS#1:
  RSAPublicKey ::= SEQUENCE {
      modulus           INTEGER,  -- n
      publicExponent    INTEGER   -- e
  }

PKCS#8:
  PublicKeyInfo ::= SEQUENCE {
    algorithm       AlgorithmIdentifier,
    PublicKey       BIT STRING
  }

  AlgorithmIdentifier ::= SEQUENCE {
    algorithm       OBJECT IDENTIFIER,
    parameters      ANY DEFINED BY algorithm OPTIONAL
  }
  也即：
  SEQUENCE(2 elem)
    SEQUENCE(2 elem)
      OBJECT IDENTIFIER1.2.840.113549.1.1.1rsaEncryption(PKCS #1)
      NULL
    BIT STRING(1 elem)
      SEQUENCE(2 elem)
        INTEGER     - Modulus
        INTEGER     - Exponent
*)
function CnRSALoadPublicKeyFromPem(const PemFileName: string;
  PublicKey: TCnRSAPublicKey): Boolean;
var
  Mem: TMemoryStream;
  Ber: TCnBerParser;
  Node: TCnBerNode;
  Buf: Pointer;
  
  procedure PutIndexedBigIntegerToBigInt(Idx: Integer; BigNumber: TCnBigNumber);
  begin
    Node := Ber.Items[Idx];
    ReallocMem(Buf, Node.BerDataLength);
    Node.CopyDataTo(Buf);
    BigNumber.SetBinary(Buf, Node.BerDataLength);
  end;

begin
  Result := False;
  Mem := nil;
  Ber := nil;

  try
    Mem := TMemoryStream.Create;
    if LoadPemFileToMemory(PemFileName, PEM_PUBLIC_HEAD, PEM_PUBLIC_TAIL, Mem) then
    begin
      // 读 PKCS#8 格式的公钥
      Ber := TCnBerParser.Create(PByte(Mem.Memory), Mem.Size, True);
      if Ber.TotalCount >= 7 then
      begin
        Buf := nil;
        // 6 和 7 整成公钥
        if PublicKey <> nil then
        begin
          PutIndexedBigIntegerToBigInt(6, PublicKey.PubKeyProduct);
          PutIndexedBigIntegerToBigInt(7, PublicKey.PubKeyExponent);
        end;

        ReallocMem(Buf, 0);
        Result := True;
      end;
    end
    else if LoadPemFileToMemory(PemFileName, PEM_RSA_PUBLIC_HEAD, PEM_RSA_PUBLIC_TAIL, Mem) then
    begin
      // 读 PKCS#1 格式的公钥
      Ber := TCnBerParser.Create(PByte(Mem.Memory), Mem.Size);
      if Ber.TotalCount >= 3 then
      begin
        Buf := nil;
        // 1 和 2 整成公钥
        if PublicKey <> nil then
        begin
          PutIndexedBigIntegerToBigInt(1, PublicKey.PubKeyProduct);
          PutIndexedBigIntegerToBigInt(2, PublicKey.PubKeyExponent);
        end;
      
        ReallocMem(Buf, 0);
        Result := True;
      end;
    end;
  finally
    Mem.Free;
    Ber.Free;
  end;
end;

// 将公钥写入 PEM 格式文件中
procedure CnRSASavePublicKeyToPem(const PemFileName: string;
  PublicKey: TCnRSAPublicKey);
begin

end;

// 利用公私钥对数据进行加解密，注意加解密使用的是同一套机制，无需区分
function RSACrypt(Data: TCnBigNumber; Product: TCnBigNumber; Exponent: TCnBigNumber;
  out Res: TCnBigNumber): Boolean;
begin
  Result := BigNumberMontgomeryPowerMod(Res, Data, Exponent, Product);
end;

// 利用上面生成的私钥对数据进行加密，返回加密是否成功
function CnRSAEncrypt(Data: TCnBigNumber; PrivateKey: TCnRSAPrivateKey;
  Res: TCnBigNumber): Boolean;
begin
  Result := RSACrypt(Data, PrivateKey.PrivKeyProduct, PrivateKey.PrivKeyExponent, Res);
end;

// 利用上面生成的公钥对数据进行解密，返回解密是否成功
function CnRSADecrypt(Res: TCnBigNumber; PublicKey: TCnRSAPublicKey;
  Data: TCnBigNumber): Boolean;
begin
  Result := RSACrypt(Res, PublicKey.PubKeyProduct, PublicKey.PubKeyExponent, Data);
end;

{ TCnRSAPrivateKey }

procedure TCnRSAPrivateKey.Clear;
begin
  FPrimeKey1.Clear;
  FPrimeKey2.Clear;
  FPrivKeyProduct.Clear;
  FPrivKeyExponent.Clear;
end;

constructor TCnRSAPrivateKey.Create;
begin
  FPrimeKey1 := TCnBigNumber.Create;
  FPrimeKey2 := TCnBigNumber.Create;
  FPrivKeyProduct := TCnBigNumber.Create;
  FPrivKeyExponent := TCnBigNumber.Create;
end;

destructor TCnRSAPrivateKey.Destroy;
begin
  FPrimeKey1.Free;
  FPrimeKey2.Free;
  FPrivKeyProduct.Free;
  FPrivKeyExponent.Free;
  inherited;
end;

{ TCnRSAPublicKey }

procedure TCnRSAPublicKey.Clear;
begin
  FPubKeyProduct.Clear;
  FPubKeyExponent.Clear;
end;

constructor TCnRSAPublicKey.Create;
begin
  FPubKeyProduct := TCnBigNumber.Create;
  FPubKeyExponent := TCnBigNumber.Create;
end;

destructor TCnRSAPublicKey.Destroy;
begin
  FPubKeyExponent.Free;
  FPubKeyProduct.Free;
  inherited;
end;

end.
