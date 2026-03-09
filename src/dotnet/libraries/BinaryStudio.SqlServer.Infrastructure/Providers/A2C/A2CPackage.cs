//#define USE_ASYNC
using System;
using System.Data;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using SharpCompress.Archives;
using SharpCompress.Archives.SevenZip;
using SharpCompress.Compressors;
using SharpCompress.Compressors.Deflate;

namespace BinaryStudio.SqlServer.Infrastructure.A2C
    {
    public class A2CPackage: SqlModelObject
        {
        public Int32 FileVersion { get; }
        public Int64 Length { get; }

        #region ctor{Int32,Int64}
        private A2CPackage(Int32 FileVersion,Int64 Length)
            {
            this.FileVersion = FileVersion;
            this.Length = Length;
            }
        #endregion
        #region ctor
        private A2CPackage(Int64 Length)
            {
            this.FileVersion = 1;
            this.Length = Length;
            }
        #endregion

        #region M:LoadFrom(String):A2CPackage
        public static A2CPackage LoadFrom(String filename) {
            using (var stream = File.OpenRead(filename)) {
                return LoadFrom(stream);
                }
            }
        #endregion
        #region M:LoadFrom(Stream):A2CPackage
        public static A2CPackage LoadFrom(Stream stream) {
            if (stream == null) { throw new ArgumentNullException(nameof(stream)); }
            var buffer = new Byte[4];
            stream.Read(buffer,0,buffer.Length);
            if ((buffer[0] == 24) || (buffer[1] == 0) ||
                (buffer[2] == 25) || (buffer[3] == 0))
                {
                var version = ReadUInt16(stream);
                var length  = ReadInt64(stream);
                using (var reader = new GZipStream(stream,CompressionMode.Decompress)) {
                    var r = new A2CPackage(version,length);
                    r.ReadFrom(reader);
                    return r;
                    }
                }
            if ((buffer[0] == '7') || (buffer[1] == 'z')) {
                stream.Seek(-2,SeekOrigin.Current);
                using (var archive = SevenZipArchive.OpenArchive(stream)) {
                    var r = new A2CPackage(archive.TotalUncompressedSize);
                    r.ReadFrom(archive);
                    return r;
                    }
                }
            throw new NotSupportedException();
            }
        #endregion
        #region M:ReadFrom(GZipStream)
        private void ReadFrom(GZipStream stream) {
            if (stream == null) { throw new ArgumentNullException(nameof(stream)); }
            using (var ds = new DataSet()) {
                ds.ReadXml(stream);
                ReadFrom(ds);
                }
            }
        #endregion
        #region M:ReadFrom(IArchive)
        private void ReadFrom(IArchive archive) {
            if (archive == null) { throw new ArgumentNullException(nameof(archive)); }
            foreach (var entry in archive.Entries) {
                if (!entry.IsDirectory) {
                    using (var ds = new DataSet()) {
                        ds.ReadXml(entry.OpenEntryStream());
                        ReadFrom(ds);
                        }
                    break;
                    }
                }
            }
        #endregion
        #region M:ReadFrom(DataSet)
        private void ReadFrom(DataSet source) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            #if USE_ASYNC
            var tasks = new List<Task>();
            using (var cancellation = new CancellationTokenSource()) {
                var token = cancellation.Token;
                foreach (DataTable table in source.Tables) {
                    var task = LoadTable(token,table);
                    lock (tasks)
                        {
                        tasks.Add(task);
                        }
                    }
                Task.WaitAll(tasks.ToArray());
                }
            #else
            foreach (DataTable table in source.Tables) {
                LoadTable(table);
                }
            #endif
            }
        #endregion
        #region M:LoadTable(CancellationToken,DataTable):Task
        private async Task LoadTable(CancellationToken cancellation,DataTable source) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            cancellation.ThrowIfCancellationRequested();
            switch (source.TableName) {
                #region DEF_META
                case "DEF_META":
                    {
                    await LoadSqlObjects(cancellation,source);
                    }
                    break;
                #endregion
                }
            }
        #endregion
        #region M:LoadTable(DataTable):Task
        private void LoadTable(DataTable source) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            switch (source.TableName) {
                #region DEF_META
                case "DEF_META":
                    {
                    LoadSqlObjects(source);
                    }
                    break;
                #endregion
                }
            }
        #endregion
        #region ReadInt16(Stream):Int16
        private static Int16 ReadInt16(Stream stream) {
            var buffer = new Byte[sizeof(Int16)];
            stream.Read(buffer,0,sizeof(Int16));
            return BitConverter.ToInt16(buffer,0);
            }
        #endregion
        #region ReadInt64(Stream):Int64
        private static Int64 ReadInt64(Stream stream) {
            var buffer = new Byte[sizeof(Int64)];
            stream.Read(buffer,0,sizeof(Int64));
            return BitConverter.ToInt64(buffer,0);
            }
        #endregion
        #region ReadUInt16(Stream):UInt16
        private static UInt16 ReadUInt16(Stream stream) {
            var buffer = new Byte[sizeof(UInt16)];
            stream.Read(buffer,0,sizeof(UInt16));
            return BitConverter.ToUInt16(buffer,0);
            }
        #endregion
        #region M:LoadSqlObjects(CancellationToken):Task
        private async Task LoadSqlObjects(CancellationToken cancellation,DataTable source) {
            await Task.Delay(0,cancellation);
            foreach (DataRow row in source.Rows) {
                var type = PropE<SqlObjectType>(row["MTYPE"],SqlObjectType.None);
                var script = row["SQLTEXT"]?.ToString();
                if (!String.IsNullOrWhiteSpace(script)) {
                    if (type != SqlObjectType.None) {
                        switch (type) {
                            case SqlObjectType.None:
                                break;
                            case SqlObjectType.ScriptBefore:
                                (new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.Table:
                                (new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.Function:
                                (new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.Procedure:
                                (new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.Index:
                                (new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.Trigger:
                                (new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.ForeignKeyConstraint:
                                (new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.View:
                                (new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.CheckConstraint:
                                (new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.Statistics:
                                (new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.Assembly:
                                (new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.TableType:
                                (new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.PartitionFunction:
                                (new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.PartitionScheme:
                                (new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.ScriptAfter:
                                (new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            default: throw new ArgumentOutOfRangeException();
                            }
                        }
                    }
                }
            }
        #endregion
        #region M:LoadSqlObjects
        private void LoadSqlObjects(DataTable source) {
            foreach (DataRow row in source.Rows) {
                var type = PropE<SqlObjectType>(row["MTYPE"],SqlObjectType.None);
                var script = row["SQLTEXT"]?.ToString();
                if (!String.IsNullOrWhiteSpace(script)) {
                    script = @"
alter table [dbo].[FC_FAILURERATES_FARS_FACODE] drop constraint [_ConstraintName];
alter table [dbo].[FC_FAILURERATES_FARS_FACODE] alter column [ID] bigint not null;
alter table [dbo].[FC_FAILURERATES_FARS_FACODE] add primary key clustered ([ID] asc) with fillfactor = 19;
";


                    if (type != SqlObjectType.None) {
                        switch (type) {
                            case SqlObjectType.None:
                                break;
                            case SqlObjectType.ScriptBefore:
                                //(new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.Table:
                                //(new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.Function:
                                //(new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.Procedure:
                                //(new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.Index:
                                //(new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.Trigger:
                                //(new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.ForeignKeyConstraint:
                                (new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.View:
                                //(new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.CheckConstraint:
                                //(new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.Statistics:
                                //(new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.Assembly:
                                //(new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.TableType:
                                //(new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.PartitionFunction:
                                //(new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.PartitionScheme:
                                //(new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            case SqlObjectType.ScriptAfter:
                                //(new SqlIndexScriptDecoder()).Decode(script);
                                break;
                            default: throw new ArgumentOutOfRangeException();
                            }
                        }
                    }
                }
            }
        #endregion
        }
    }