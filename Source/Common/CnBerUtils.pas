{******************************************************************************}
{                       CnPack For Delphi/C++Builder                           }
{                     �й����Լ��Ŀ���Դ�������������                         }
{                   (C)Copyright 2001-2018 CnPack ������                       }
{                   ------------------------------------                       }
{                                                                              }
{            ���������ǿ�Դ���������������������� CnPack �ķ���Э������        }
{        �ĺ����·�����һ����                                                }
{                                                                              }
{            ������һ��������Ŀ����ϣ�������ã���û���κε���������û��        }
{        �ʺ��ض�Ŀ�Ķ������ĵ���������ϸ���������� CnPack ����Э�顣        }
{                                                                              }
{            ��Ӧ���Ѿ��Ϳ�����һ���յ�һ�� CnPack ����Э��ĸ��������        }
{        ��û�У��ɷ������ǵ���վ��                                            }
{                                                                              }
{            ��վ��ַ��http://www.cnpack.org                                   }
{            �����ʼ���master@cnpack.org                                       }
{                                                                              }
{******************************************************************************}

unit CnBerUtils;
{* |<PRE>
================================================================================
* �������ƣ�������������
* ��Ԫ���ƣ����� ASN.1 �� BER ���뵥Ԫ
* ��Ԫ���ߣ���Х
* ��    ע��
* ����ƽ̨��WinXP + Delphi 5.0
* ���ݲ��ԣ���δ����
* �� �� �����õ�Ԫ���豾�ػ�����
* �޸ļ�¼��2018.05.27 V1.1
*               �� Parser ��Ϊ Reader ��ʵ�� Writer
*           2018.05.24 V1.0
*               ������Ԫ
================================================================================
|</PRE>}

interface

{$I CnPack.inc}

uses
  SysUtils, Classes, Windows, TypInfo, CnTree {$IFDEF DEBUG}, ComCtrls {$ENDIF};

const
  CN_BER_TAG_TYPE_MASK                      = $C0;
  CN_BER_TAG_STRUCT_MASK                    = $20;
  CN_BER_TAG_VALUE_MASK                     = $1F;
  CN_BER_LENLEN_MASK                        = $80;
  CN_BER_LENGTH_MASK                        = $7F;

  CN_BER_TAG_RESERVED                       = $00;
  CN_BER_TAG_BOOLEAN                        = $01;
  CN_BER_TAG_INTEGER                        = $02;
  CN_BER_TAG_BIT_STRING                     = $03;
  CN_BER_TAG_OCTET_STRING                   = $04;
  CN_BER_TAG_NULL                           = $05;
  CN_BER_TAG_OBJECT_IDENTIFIER              = $06;
  CN_BER_TAG_OBJECT_DESCRIPION              = $07;
  CN_BER_TAG_EXTERNAL                       = $08;
  CN_BER_TAG_REAL                           = $09;
  CN_BER_TAG_ENUMERATED                     = $0A;
  CN_BER_TAG_EMBEDDED_PDV                   = $0B;
  CN_BER_TAG_UFT8STRING                     = $0C;
  CN_BER_TAG_RELATIVE_OID                   = $0D;

  CN_BER_TAG_SEQUENCE                       = $10;
  CN_BER_TAG_SET                            = $11;
  CN_BER_TAG_NUMERICSTRING                  = $12;
  CN_BER_TAG_PRINTABLESTRING                = $13;
  CN_BER_TAG_TELETEXSTRING                  = $14;
  CN_BER_TAG_VIDEOTEXSTRING                 = $15;
  CN_BER_TAG_IA5STRING                      = $16;
  CN_BER_TAG_UTCTIME                        = $17;
  CN_BER_TAG_GENERALIZEDTIME                = $18;
  CN_BER_TAG_GRAPHICSTRING                  = $19;
  CN_BER_TAG_VISIBLESTRING                  = $1A;
  CN_BER_TAG_GENERALSTRING                  = $1B;
  CN_BER_TAG_UNIVERSALSTRING                = $1C;
  CN_BER_TAG_CHARACTER_STRING               = $1D;
  CN_BER_TAG_BMPSTRING                      = $1E;

type
  TCnBerTag = (cbtReserved_0, cbtBoolean, cbtInteger, cbtBit_String,
    cbtOctet_String, cbtNull, cbtObject_Identifier, cbtObject_Descripion,
    cbtExternal, cbtReal, cbtEnumerated, cbtEmbedded_Pdv, cbtUft8String,
    cbtRelative_Oid, cbtReserved_0E, cbtReserved_0F, cbtSequence, cbtSet,
    cbtNumericString, cbtPrintableString, cbtTeletexString, cbtVideotexString,
    cbtIa5String, cbtUtcTime, cbtGeneralizedTime, cbtGraphicString,
    cbtVisibleString, cbtGeneralString, cbtUniversalString, cbtCharacter_String,
    cbtBmpstring);

  TCnBerTags = set of TCnBerTag;

  TCnBerReadNode = class(TCnLeaf)
  {* ����һ���������� ASN.1 �ڵ�}
  private
    FOriginData: PByte;
    FBerLength: Integer;
    FBerOffset: Integer;
    FBerTag: Integer;
    FBerDataLength: Integer;
    FBerDataOffset: Integer;
    function GetItems(Index: Integer): TCnBerReadNode;
    procedure SetItems(Index: Integer; const Value: TCnBerReadNode);

    function InternalAsInt(ByteSize: Integer): Integer;
    function GetBerDataAddress: Pointer;
  public
    procedure CopyDataTo(DestBuf: Pointer);
    {* �����ݸ��������������������ߴ�������Ҫ BerDataLength ��}

    function AsShortInt: ShortInt;
    function AsByte: Byte;
    function AsSmallInt: SmallInt;
    function AsWord: Word;
    function AsInteger: Integer;
    function AsCardinal: Cardinal;
    function AsInt64: Int64;

    property Items[Index: Integer]: TCnBerReadNode read GetItems write SetItems;

    property BerOffset: Integer read FBerOffset write FBerOffset;
    {* �ýڵ��Ӧ�� ASN.1 ���ݱ����������е�ƫ��}
    property BerLength: Integer read FBerLength write FBerLength;
    {* �����ڵ�����ݳ���}

    property BerTag: Integer read FBerTag write FBerTag;
    {* �ڵ����ͣ�Ҳ���� Tag}
    property BerDataLength: Integer read FBerDataLength write FBerDataLength;
    {* �ڵ����ݳ���}
    property BerDataOffset: Integer read FBerDataOffset write FBerDataOffset;
    {* �ýڵ��Ӧ�����������������е�ƫ��}
    property BerDataAddress: Pointer read GetBerDataAddress;
    {* �ýڵ��Ӧ�����ݵ���ʼ��ַ������ FOriginData + FBerDataOffset}
  end;

  TCnBerReader = class
  {* ��ȡ������ BER �������ݿ�Ľ�������}
  private
    FBerTree: TCnTree;
    FData: PByte;
    FDataLen: Cardinal;
    FParseInnerString: Boolean;
{$IFDEF DEBUG}
    function GetOnSaveNode: TCnTreeNodeEvent;
    procedure SetOnSaveNode(const Value: TCnTreeNodeEvent);
{$ENDIF}
    function GetTotalCount: Integer;
    function GetItems(Index: Integer): TCnBerReadNode;
    procedure ParseArea(Parent: TCnLeaf; AData: PByteArray;
      ADataLen: Cardinal; AStartOffset: Cardinal);
    {* ����һ�����ݣ�������������� ASN.1 �ڵ����ι��� Parent �ڵ���}
  protected
    procedure ParseToTree;
  public
    constructor Create(Data: PByte; DataLen: Cardinal; AParseInnerString: Boolean = False);
    destructor Destroy; override;

{$IFDEF DEBUG}
    procedure DumpToTreeView(ATreeView: TTreeView);
    property OnSaveNode: TCnTreeNodeEvent read GetOnSaveNode write SetOnSaveNode;
{$ENDIF}

    property ParseInnerString: Boolean read FParseInnerString;
    {* �Ƿ� BitString/OctetString ����Ҳ��������������������PKCS#8 �� Pem �ļ��г���}
    property TotalCount: Integer read GetTotalCount;
    {* ���������� ASN.1 �ڵ�����}
    property Items[Index: Integer]: TCnBerReadNode read GetItems;
    {* ˳��������н��������� ASN.1 �ڵ㣬�±�� 0 ��ʼ�������� Tree ������ Root}
  end;

  TCnBerWriteNode = class(TCnLeaf)
  {* ����һ���ڱ��벢д��� ASN.1 �ڵ�}
  private
    FMem: TMemoryStream; // ���ɻ������ͽڵ���������ݣ���ֻ��������
    FHead: array[0..5] of Byte; // ����������֮ǰ��ͷ���ݣ����� Tag��Len ��
    FHeadLen: Integer;
    FIsContainer: Boolean;
    FDataLength: Integer;
    FData: Pointer;
    FBerTag: Integer;
    function GetIsContainer: Boolean;
    procedure SetIsContainer(const Value: Boolean);
    function GetItems(Index: Integer): TCnBerWriteNode;
    procedure SetItems(Index: Integer; const Value: TCnBerWriteNode);

    procedure FillHeadCalcLen(ATag, ADataLen: Integer); // ���㲢��� FHead �� FHeadLen
  public
    constructor Create(ATree: TCnTree); override;
    destructor Destroy; override;

    function SaveToStream(Stream: TStream): Integer;
    {* ����ǻ������;ͽ��Լ�д����������д�볤�ȣ�
      ����������򰤸����ӽڵ�д������Ȼ����Լ�ͷ��ƴ������ƴ���ӽڵ�ķ��س��ȡ�
      ����ֵΪ���ڵ�����ӽڵ���������ݳ���}

    function GetNodeLength: Integer;
    {* ����ǻ������;ͷ����������ȣ�������������Լ�ͷ�Ӹ��ӽڵ㳤��}

    procedure FillBasicNode(ATag: Integer; Data: PByte; DataLen: Integer);
    {* ��紴���˻����ڵ���ô˷������������ݣ�Container �ڵ㲻��}

    property Items[Index: Integer]: TCnBerWriteNode read GetItems write SetItems;

    property Data: Pointer read FData write FData;
    property DataLength: Integer read FDataLength write FDataLength;
    property IsContainer: Boolean read GetIsContainer write SetIsContainer;

    property BerTag: Integer read FBerTag write FBerTag;
    {* �ڵ����ͣ�Ҳ���� Tag}
  end;

  TCnBerWriter = class
  {* д BER ��������ݵĹ�����}
  private
    FBerTree: TCnTree;
    function GetTotalSize: Integer;
{$IFDEF DEBUG}
    function GetOnSaveNode: TCnTreeNodeEvent;
    procedure SetOnSaveNode(const Value: TCnTreeNodeEvent);
{$ENDIF}
  public
    constructor Create;
    destructor Destroy; override;

    procedure SaveTo(DestBuf: Pointer);
    procedure SaveToFile(const FileName: string);
    procedure SaveToStream(Stream: TStream);

{$IFDEF DEBUG}
    procedure DumpToTreeView(ATreeView: TTreeView);
    property OnSaveNode: TCnTreeNodeEvent read GetOnSaveNode write SetOnSaveNode;
{$ENDIF}

    function AddNullNode(Parent: TCnBerWriteNode = nil): TCnBerWriteNode;
    {* ����һ�� Null �ڵ�}
    function AddBasicNode(ATag: Integer; AData: PByte; DataLen: Integer;
      Parent: TCnBerWriteNode = nil): TCnBerWriteNode;
    {* ����һ���������͵Ľڵ㣬���ݴ� AData ���Ƴ���Ϊ DataLen �Ķ���}
    function AddContainerNode(ATag: Integer; Parent: TCnBerWriteNode = nil): TCnBerWriteNode;
    {* ����һ���������͵Ľڵ㣬�˽ڵ������Ϊ���� BasicNode �� Parent}

    property TotalSize: Integer read GetTotalSize;
  end;

implementation

function GetTagName(Tag: Integer): string;
begin
  Result := 'Invalid';
  if Tag in [Ord(Low(TCnBerTag))..Ord(High(TCnBerTag))] then
  begin
    Result := GetEnumName(TypeInfo(TCnBerTag), Tag);
    if (Length(Result) > 3) and (Copy(Result, 1, 3) = 'cbt') then
      Delete(Result, 1, 3);
  end;
end;

function SwapWord(Value: Word): Word;
begin
  Result := ((Value and $FF00) shr 8) or ((Value and $00FF) shl 8);
end;

function SwapLongWord(Value: LongWord): LongWord;
begin
  Result := ((Value and $000000FF) shl 24) or ((Value and $0000FF00) shl 8)
    or ((Value and $00FF0000) shr 8) or ((Value and $FF000000) shr 24);
end;

function SwapInt64(Value: Int64): Int64;
var
  Lo, Hi: LongWord;
  Rec: Int64Rec;
begin
  Lo := Int64Rec(Value).Lo;
  Hi := Int64Rec(Value).Hi;
  Lo := SwapLongWord(Lo);
  Hi := SwapLongWord(Hi);
  Rec.Lo := Hi;
  Rec.Hi := Lo;
  Result := Int64(Rec);
end;

{ TCnBerParser }

constructor TCnBerReader.Create(Data: PByte; DataLen: Cardinal;
  AParseInnerString: Boolean);
begin
  FData := Data;
  FDataLen := DataLen;
  FParseInnerString := AParseInnerString;
  FBerTree := TCnTree.Create(TCnBerReadNode);

  ParseToTree;
end;

destructor TCnBerReader.Destroy;
begin
  inherited;

end;

{$IFDEF DEBUG}

procedure TCnBerReader.DumpToTreeView;
begin
  FBerTree.SaveToTreeView(ATreeView);
end;

function TCnBerReader.GetOnSaveNode: TCnTreeNodeEvent;
begin
  Result := FBerTree.OnSaveANode;
end;

procedure TCnBerReader.SetOnSaveNode(const Value: TCnTreeNodeEvent);
begin
  FBerTree.OnSaveANode := Value;
end;

{$ENDIF}

function TCnBerReader.GetItems(Index: Integer): TCnBerReadNode;
begin
  Result := TCnBerReadNode(FBerTree.Items[Index + 1]);
end;

function TCnBerReader.GetTotalCount: Integer;
begin
  Result := FBerTree.Root.AllCount;
end;

procedure TCnBerReader.ParseArea(Parent: TCnLeaf; AData: PByteArray;
  ADataLen: Cardinal; AStartOffset: Cardinal);
var
  Run, Start: Cardinal;
  Tag, DataLen, DataOffset, LenLen, Delta: Integer;
  B: Byte;
  IsStruct: Boolean;
  ALeaf: TCnBerReadNode;
begin
  Run := 0;  // Run �ǻ��� AData ��ʼ����ƫ����

  while Run < ADataLen do
  begin
    B := AData[Run];

    if B = $FF then
      Exit;

    Start := Run;

    // ���� Tag ����
    IsStruct := (B and CN_BER_TAG_STRUCT_MASK) <> 0;
    Tag := B and CN_BER_TAG_VALUE_MASK;

    Inc(Run);
    if Run >= ADataLen then
      raise Exception.Create('Data Corruption when Processing Tag.');

    // Run ָ�򳤶ȣ���������
    Delta := 1;  // 1 ��ʾ Tag ��ռ�ֽ�
    B := AData[Run];
    if (B and CN_BER_LENLEN_MASK) = 0 then
    begin
      // ���ֽھ��ǳ���
      DataLen := B;
      DataOffset := AStartOffset + Run + 1;
      Inc(Delta); // ���ϳ��ȵ���һ�ֽ�
      Inc(Run);   // Run ָ������
    end
    else
    begin
      // ���ֽڸ�λΪ 1����ʾ���ȵĳ���
      LenLen := B and CN_BER_LENGTH_MASK;
      Inc(Delta); // ���ϳ��ȵĳ�����һ�ֽ�
      Inc(Run);   // Run ָ�򳤶�

      // AData[Run] �� AData[Run + LenLen - 1] �ǳ���
      if Run + Cardinal(LenLen) - 1 >= ADataLen then
        raise Exception.Create('Data Corruption when Processing Tag.');

      if LenLen = SizeOf(Byte) then
        DataLen := AData[Run]
      else if LenLen = SizeOf(Word) then
        DataLen := (Cardinal(AData[Run]) shl 8) or Cardinal(AData[Run + 1])
      else // if LenLen > SizeOf(Word) then
        raise Exception.Create('Length Too Long: ' + IntToStr(LenLen));

      DataOffset := AStartOffset + Run + Cardinal(LenLen);
      Inc(Delta, LenLen);
      Inc(Run, LenLen);   // Run ָ������
    end;

    // Tag, Len, DataOffset ����ȫ�ˣ�Delta ��������ʼ���뵱ǰ�ڵ���ʼ����ƫ��
    if Parent = nil then
      Parent := FBerTree.Root;

    ALeaf := FBerTree.AddChild(Parent) as TCnBerReadNode;
    ALeaf.FOriginData := FData;

    ALeaf.BerOffset := AStartOffset + Start;
    ALeaf.BerLength := DataLen + Delta;
    ALeaf.BerTag := Tag;
    ALeaf.BerDataLength := DataLen;
    ALeaf.BerDataOffset := DataOffset;

{$IFDEF DEBUG}
    ALeaf.Text := Format('Offset %d. Len %d. Tag %d (%s). DataLen %d', [ALeaf.BerOffset,
      ALeaf.BerLength, ALeaf.BerTag, GetTagName(ALeaf.BerTag), ALeaf.BerDataLength]);
{$ENDIF}

    if IsStruct or (FParseInnerString and (ALeaf.BerTag in [CN_BER_TAG_BIT_STRING,
      CN_BER_TAG_OCTET_STRING])) then
    begin
      // ˵�� BerDataOffset �� BerDataLength �����ӽڵ�

      if ALeaf.BerTag = CN_BER_TAG_BIT_STRING then
      begin
        // BIT_STRING ��������һ�������ֽ��Ǹ� BIT_STRING �ճ� 8 �ı�����ȱ�ٵ� Bit ������������
        ParseArea(ALeaf, PByteArray(Cardinal(AData) + Run + 1),
          ALeaf.BerDataLength - 1, ALeaf.BerDataOffset + 1);
      end
      else
        ParseArea(ALeaf, PByteArray(Cardinal(AData) + Run),
          ALeaf.BerDataLength, ALeaf.BerDataOffset);
    end;

    Inc(Run, DataLen);
  end;
end;

procedure TCnBerReader.ParseToTree;
begin
  ParseArea(FBerTree.Root, PByteArray(FData), FDataLen, 0);
end;

{ TCnBerNode }

function TCnBerReadNode.InternalAsInt(ByteSize: Integer): Integer;
var
  IntValue: Integer;
begin
  if FBerTag <> CN_BER_TAG_INTEGER then
    raise Exception.Create('Ber Tag Type Mismatch for ByteSize: ' + IntToStr(ByteSize));

  if not (ByteSize in [SizeOf(Byte)..SizeOf(Integer)]) then
    raise Exception.Create('Invalid ByteSize: ' + IntToStr(ByteSize));

  if FBerDataLength > ByteSize then
    raise Exception.CreateFmt('Data Length %d Overflow for Required %d.',
      [FBerDataLength, ByteSize]);

  IntValue := 0;
  CopyDataTo(@IntValue);
  IntValue := SwapLongWord(IntValue);
  Result := IntValue;
end;

function TCnBerReadNode.AsInt64: Int64;
begin
  if FBerTag <> CN_BER_TAG_INTEGER then
    raise Exception.Create('Ber Tag Type Mismatch for Int64: ' + IntToStr(FBerTag));

  if FBerDataLength > SizeOf(Int64) then
    raise Exception.CreateFmt('Data Length %d Overflow for Required %d.',
      [FBerDataLength, SizeOf(Int64)]);

  Result := 0;
  CopyDataTo(@Result);
  Result := SwapInt64(Result);
end;

function TCnBerReadNode.AsByte: Byte;
begin
  Result := Byte(InternalAsInt(SizeOf(Byte)));
end;

function TCnBerReadNode.AsCardinal: Cardinal;
begin
  Result := Cardinal(InternalAsInt(SizeOf(Cardinal)));
end;

function TCnBerReadNode.AsInteger: Integer;
begin
  Result := Integer(InternalAsInt(SizeOf(Integer)));
end;

function TCnBerReadNode.AsShortInt: ShortInt;
begin
  Result := ShortInt(InternalAsInt(SizeOf(ShortInt)));
end;

function TCnBerReadNode.AsSmallInt: SmallInt;
begin
  Result := SmallInt(InternalAsInt(SizeOf(SmallInt)));
end;

function TCnBerReadNode.AsWord: Word;
begin
  Result := Word(InternalAsInt(SizeOf(Word)));
end;

procedure TCnBerReadNode.CopyDataTo(DestBuf: Pointer);
begin
  if (FOriginData <> nil) and (FBerDataLength > 0) then
    CopyMemory(DestBuf, Pointer(Integer(FOriginData) + FBerDataOffset), FBerDataLength);
end;

function TCnBerReadNode.GetItems(Index: Integer): TCnBerReadNode;
begin
  Result := inherited GetItems(Index) as TCnBerReadNode;
end;

procedure TCnBerReadNode.SetItems(Index: Integer; const Value: TCnBerReadNode);
begin
  inherited SetItems(Index, Value);
end;

function TCnBerReadNode.GetBerDataAddress: Pointer;
begin
  if FOriginData = nil then
    Result := nil
  else
    Result := Pointer(Integer(FOriginData) + FBerDataOffset);
end;

{ TCnBerWriter }

function TCnBerWriter.AddBasicNode(ATag: Integer; AData: PByte;
  DataLen: Integer; Parent: TCnBerWriteNode): TCnBerWriteNode;
begin
  if Parent = nil then
    Parent := FBerTree.Root as TCnBerWriteNode;

  Result := FBerTree.AddChild(Parent) as TCnBerWriteNode;
  Result.FIsContainer := False;
  Result.FillBasicNode(ATag, AData, DataLen);
end;

function TCnBerWriter.AddContainerNode(ATag: Integer;
  Parent: TCnBerWriteNode): TCnBerWriteNode;
begin
  if Parent = nil then
    Parent := FBerTree.Root as TCnBerWriteNode;

  Result := FBerTree.AddChild(Parent) as TCnBerWriteNode;
  Result.BerTag := ATag;
  Result.IsContainer := True;
end;

function TCnBerWriter.AddNullNode(Parent: TCnBerWriteNode): TCnBerWriteNode;
begin
  if Parent = nil then
    Parent := FBerTree.Root as TCnBerWriteNode;

  Result := FBerTree.AddChild(Parent) as TCnBerWriteNode;
  Result.IsContainer := False;
  Result.FillBasicNode(CN_BER_TAG_NULL, nil, 0); // TODO: Null ������
end;

constructor TCnBerWriter.Create;
begin
  inherited;
  FBerTree := TCnTree.Create(TCnBerWriteNode);
end;

destructor TCnBerWriter.Destroy;
begin
  FBerTree.Free;
  inherited;
end;

{$IFDEF DEBUG}

procedure TCnBerWriter.DumpToTreeView(ATreeView: TTreeView);
begin
  FBerTree.SaveToTreeView(ATreeView);
end;

function TCnBerWriter.GetOnSaveNode: TCnTreeNodeEvent;
begin
  Result := FBerTree.OnSaveANode;
end;

procedure TCnBerWriter.SetOnSaveNode(const Value: TCnTreeNodeEvent);
begin
  FBerTree.OnSaveANode := Value;
end;

{$ENDIF}

function TCnBerWriter.GetTotalSize: Integer;
var
  I: Integer;
begin
  Result := 0;
  for I := 0 to FBerTree.Root.Count - 1 do
    Result := Result + TCnBerWriteNode(FBerTree.Root).Items[I].GetNodeLength;
end;

procedure TCnBerWriter.SaveTo(DestBuf: Pointer);
var
  Mem: TMemoryStream;
begin
  Mem := TMemoryStream.Create;
  try
    SaveToStream(Mem);
    Mem.Write(DestBuf^, Mem.Size);
  finally
    Mem.Free;
  end;
end;

procedure TCnBerWriter.SaveToFile(const FileName: string);
var
  Stream: TFileStream;
begin
  Stream := TFileStream.Create(FileName, fmCreate);
  try
    SaveToStream(Stream);
  finally
    Stream.Free;
  end;
end;

procedure TCnBerWriter.SaveToStream(Stream: TStream);
var
  I: Integer;
begin
  for I := 0 to FBerTree.Root.Count - 1 do
    TCnBerWriteNode(FBerTree.Root).Items[I].SaveToStream(Stream);
end;

{ TCnBerWriteNode }

procedure TCnBerWriteNode.FillHeadCalcLen(ATag, ADataLen: Integer);
var
  LenLen: Cardinal;
  B: Byte;
  W: Word;
  D: Cardinal;
begin
  FHeadLen := 0;
  if FIsContainer and (FBerTag in [CN_BER_TAG_SEQUENCE, CN_BER_TAG_SET]) then
    FHead[0] := ATag or CN_BER_TAG_STRUCT_MASK // ���ӽڵ�����ָ�����ͣ���λ�� 1
  else
    FHead[0] := ATag;

  Inc(FHeadLen);
  if FBerTag = CN_BER_TAG_BIT_STRING then // BitString ����ȥҪ�Ӹ�ͷ�ֽ�
    Inc(ADataLen);

  if ADataLen <= 127 then // ���ֽڳ���
  begin
    FHead[1] := ADataLen;
    Inc(FHeadLen);
  end
  else
  begin
    // ���ڻ���� 128������ LeafLen ���ֽ���
    if ADataLen < $100 then
    begin
      LenLen := 1;
      B := ADataLen;
      CopyMemory(@FHead[2], @B, LenLen);
    end
    else if ADataLen < $10000 then
    begin
      LenLen := 2;
      W := ADataLen;
      W := SwapWord(W);
      CopyMemory(@FHead[2], @W, LenLen);
    end
    else if ADataLen < $1000000 then
    begin
      LenLen := 3;
      D := ADataLen;
      D := SwapLongWord(D);
      D := D shr 8;
      CopyMemory(@FHead[2], @D, LenLen);
    end
    else
    begin
      LenLen := 4;
      D := ADataLen;
      D := SwapLongWord(D);
      CopyMemory(@FHead[2], @D, LenLen);
    end;

    FHead[1] := CN_BER_LENLEN_MASK or LenLen;
    Inc(FHeadLen, 1 + LenLen);
  end;
end;

constructor TCnBerWriteNode.Create(ATree: TCnTree);
begin
  inherited;
  FMem := TMemoryStream.Create;
end;

destructor TCnBerWriteNode.Destroy;
begin
  FMem.Free;
  inherited;
end;

function TCnBerWriteNode.GetIsContainer: Boolean;
begin
  Result := FIsContainer;
end;

function TCnBerWriteNode.GetItems(Index: Integer): TCnBerWriteNode;
begin
  Result := TCnBerWriteNode(inherited GetItems(Index));
end;

function TCnBerWriteNode.SaveToStream(Stream: TStream): Integer;
var
  B: Byte;
  I: Integer;
  LeafLen: Cardinal;
  AMem: TMemoryStream;
begin
  if FIsContainer then
  begin
    LeafLen := 0;
    Result := 0;
    AMem := TMemoryStream.Create;
    try
      for I := 0 to Count - 1 do
        LeafLen := LeafLen + Cardinal(Items[I].SaveToStream(AMem));

      FillHeadCalcLen(FBerTag, LeafLen);
      // �� Tag��LeafLen �Լ� AMem ��������Ϻ�д��

      Result := Result + Stream.Write(FHead[0], FHeadLen); // дͷ�볤��
      if FBerTag = CN_BER_TAG_BIT_STRING then              // BitString ��һ�� bit ������ʱ��Ϊȫ 0 ����
      begin
        B := 0;
        Result := Result + Stream.Write(B, 1);
      end;

      // д��������
      Result := Result + Stream.Write(AMem.Memory^, AMem.Size);
    finally
      AMem.Free;
    end;
  end
  else
  begin
    FMem.Position := 0;
    Result := Stream.Write(FMem.Memory^, FMem.Size);
  end;
end;

procedure TCnBerWriteNode.SetIsContainer(const Value: Boolean);
begin
  FIsContainer := Value;
end;

procedure TCnBerWriteNode.SetItems(Index: Integer;
  const Value: TCnBerWriteNode);
begin
  inherited SetItems(Index, Value);
end;

function TCnBerWriteNode.GetNodeLength: Integer;
var
  I, LeafLen: Integer;
begin
  if FIsContainer then
  begin
    LeafLen := 0;
    for I := 0 to Count - 1 do
      LeafLen := LeafLen + Items[I].GetNodeLength;

    FillHeadCalcLen(FBerTag, LeafLen);
    Result := FHeadLen + LeafLen;

    // BitString ��Ҫһ��ǰ���ֽڱ�ʾ����� bit
    if FBerTag = CN_BER_TAG_BIT_STRING then
      Inc(Result);
  end
  else
  begin
    Result := FMem.Size;
  end;
end;

procedure TCnBerWriteNode.FillBasicNode(ATag: Integer; Data: PByte;
  DataLen: Integer);
begin
  FBerTag := ATag;
  if FIsContainer then
    Exit;

  FData := Data;
  FDataLength := DataLen;
  FillHeadCalcLen(ATag, DataLen);

  FMem.Clear;
  FMem.Write(FHead[0], FHeadLen);
  if DataLen > 0 then
    FMem.Write(Data^, DataLen);
end;

end.