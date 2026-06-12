#define USE_ASYNC
using System;
using System.Collections.Generic;
using System.Data;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading;
using System.Threading.Tasks;
using System.Xml.Linq;
using Microsoft.SqlServer.TransactSql.ScriptDom;
using JetBrains.Annotations;
using SharpCompress.Archives;
using SharpCompress.Archives.SevenZip;
using SharpCompress.Compressors;
using SharpCompress.Compressors.Deflate;
using BinaryStudio.SqlServer.Infrastructure;
using IPGPhotonics.PDB.Infrastructure.Properties;

namespace IPGPhotonics.PDB.Infrastructure
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    public class A2CPackage: SqlObject,ISqlExtendedPropertyResolver,
        ISqlObjectResolver<Int32?,User>,
        ISqlObjectResolver<Int32?,Module>,
        ISqlObjectResolver<Int32?,Entity>,
        ISqlObjectResolver<Int32?,Unit>,
        ISqlObjectResolver<Int32?,Class>,
        ISqlObjectResolver<Int32?,Query>,
        ISqlObjectResolver<Int32?,Interface>,
        ISqlObjectResolver<Int32?,Report>,
        ISqlObjectResolver<Int32?,View>,
        ISqlObjectResolver<Int32?,Operation>,
        ISqlObjectResolver<Int32?,ClassState>
        {
        public Int32 FileVersion { get; }
        public Int64 Length { get; }
        public IList<Module>    Modules { get;private set; }
        public IList<PDBEnum>   Enums { get;private set; }
        public IList<Entity>    Entities { get;private set; }
        public IList<Unit>      DataUnits { get;private set; }
        public IList<Query>     Queries { get;private set; }
        public IList<Stage>     Stages { get;private set; }
        public IList<Class>     Classes { get;private set; }
        public IList<Form>      Forms { get;private set; }
        public IList<Interface> Interfaces { get;private set; }
        public IList<Report>    Reports { get;private set; }
        public IList<View>      Views { get;private set; }
        public IList<Operation> Operations { get;private set; }

        #region ctor
        private A2CPackage() {
            Modules = EmptyArray<Module>.List;
            Enums = EmptyArray<PDBEnum>.List;
            Entities = EmptyArray<Entity>.List;
            DataUnits = EmptyArray<Unit>.List;
            Queries = EmptyArray<Query>.List;
            Stages = EmptyArray<Stage>.List;
            Classes = EmptyArray<Class>.List;
            Forms = EmptyArray<Form>.List;
            Interfaces = EmptyArray<Interface>.List;
            Reports = EmptyArray<Report>.List;
            Views = EmptyArray<View>.List;
            Operations = EmptyArray<Operation>.List;
            LoadUsers(Resources.PredefinedUserRecords);
            }
        #endregion
        #region ctor{Int32,Int64}
        private A2CPackage(Int32 FileVersion,Int64 Length)
            :this()
            {
            this.FileVersion = FileVersion;
            this.Length = Length;
            }
        #endregion
        #region ctor
        private A2CPackage(Int64 Length)
            :this()
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
                Task.WaitAll(LoadUsers(token,source.Tables["DEF_USERS"]));
                Task.WaitAll(LoadModules(token,source.Tables["DEF_MODULES"]));
                Task.WaitAll(
                    BuildIndex(token,source.Tables["DEF_ENTITY_FIELDS"],IXenfI,"ENTITYOID"),
                    BuildIndex(token,source.Tables["DEF_ENUMERATION_T"],IXenuV,"ENUMOID"),
                    BuildIndex(token,source.Tables["DEF_CLASS_STATES"], IXclsS,"CLASSOID",LoadClassState),
                    BuildIndex(token,source.Tables["DEF_INTERFACE_T"], IXintfI,"INTERFACEOID"),
                    LoadUnits(token,source.Tables["DEF_UNIT"]),
                    LoadForms(token,source.Tables["DEF_FORM"]),
                    LoadReports(token,source.Tables["DEF_REPORTS"])
                    );
                Task.WaitAll(LoadUnits(token,source.Tables["DEF_UNIT"]));
                Task.WaitAll(LoadForms(token,source.Tables["DEF_FORM"]));
                Task.WaitAll(LoadReports(token,source.Tables["DEF_REPORTS"]));
                Task.WaitAll(LoadEnum(token,source.Tables["DEF_ENUMERATION"]));
                Task.WaitAll(LoadQueries(token,source.Tables["DEF_SQL"]));
                Task.WaitAll(LoadEntities(token,source.Tables["DEF_ENTITY"]));
                Task.WaitAll(LoadClasses(token,source.Tables["DEF_CLASSES"]));
                Task.WaitAll(LoadViews(token,source.Tables["DEF_VIEWS"]));
                Task.WaitAll(LoadStages(token,source.Tables["DEF_STAGES"]));
                Task.WaitAll(LoadInterfaces(token,source.Tables["DEF_INTERFACE"]));
                Task.WaitAll(LoadOperations(token,source.Tables["DEF_OPERATION"]));
                //foreach (DataTable table in source.Tables) {
                //    var task = LoadTable(token,table);
                //    lock (tasks)
                //        {
                //        tasks.Add(task);
                //        }
                //    }
                //Task.WaitAll(tasks.ToArray());
                }
            #else
            foreach (DataTable table in source.Tables) {
                LoadTable(table);
                }
            #endif
            Modules   = m_modI.Values.AsReadOnly();
            Enums     = m_enuI.Values.AsReadOnly();
            Entities  = m_entI.Values.AsReadOnly();
            DataUnits = m_DuniI.Values.AsReadOnly();
            Queries   = m_querI.Values.AsReadOnly();
            Stages    = m_stagI.Values.AsReadOnly();
            Classes   = m_clasI.Values.AsReadOnly();
            Forms     = m_formI.Values.AsReadOnly();
            Interfaces = m_intfI.Values.AsReadOnly();
            Reports = m_repoI.Values.AsReadOnly();
            Views = m_viewI.Values.AsReadOnly();
            Operations = m_operI.Values.AsReadOnly();
            return;
            var TargetFolder = Path.Combine(Path.GetDirectoryName(Assembly.GetEntryAssembly().Location),@"..\..\..\..\db");
            MakeFolderIfItNotExist(TargetFolder);
            //foreach (var pair in m_tbN.Where(i => i.Key == "[dbo].[COM_TURNS]")) {
            foreach (var pair in m_tbN) {
                var ObjectName = pair.Key;
                var SchemaName = ObjectName.SchemaName.ToString();
                var TargetObjectFolder = Path.Combine(TargetFolder,SchemaName,"Tables");
                MakeFolderIfItNotExist(TargetObjectFolder);
                (new SSDTTableFormatter{
                    IgnorePrimaryKeySystemName = true,
                    IgnoreDefaultConstraintSystemName = true,
                    IgnorePrimaryKeyOptions = true,
                    IgnoreIndexOptions = true
                    }).WriteTo(this,pair.Value,out var script);
                File.WriteAllText(Path.Combine(TargetObjectFolder,$"{ObjectName.ObjectName}.sql"),script,Encoding.UTF8);
                }
            return;
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
                #region DEF_USERS
                case "DEF_USERS":
                    {
                    await LoadUsers(cancellation,source);
                    }
                    break;
                #endregion
                #region DEF_MODULES
                case "DEF_MODULES":
                    {
                    await LoadModules(cancellation,source);
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
                    //LoadSqlObjects(source);
                    }
                    break;
                #endregion
                #region DEF_MODULES
                case "DEF_MODULES":
                    {
                    LoadModules(CancellationToken.None,source).Wait();
                    }
                    break;
                #endregion
                }
            }
        #endregion
        #region M:ReadInt16(Stream):Int16
        private static Int16 ReadInt16(Stream stream) {
            var buffer = new Byte[sizeof(Int16)];
            stream.Read(buffer,0,sizeof(Int16));
            return BitConverter.ToInt16(buffer,0);
            }
        #endregion
        #region M:ReadInt64(Stream):Int64
        private static Int64 ReadInt64(Stream stream) {
            var buffer = new Byte[sizeof(Int64)];
            stream.Read(buffer,0,sizeof(Int64));
            return BitConverter.ToInt64(buffer,0);
            }
        #endregion
        #region M:ReadUInt16(Stream):UInt16
        private static UInt16 ReadUInt16(Stream stream) {
            var buffer = new Byte[sizeof(UInt16)];
            stream.Read(buffer,0,sizeof(UInt16));
            return BitConverter.ToUInt16(buffer,0);
            }
        #endregion
        #region M:LoadClasses(CancellationToken,DataTable):Task
        private async Task LoadClasses(CancellationToken cancellation,DataTable source) {
            await Task.Delay(0,cancellation);
            await Task.Run(() => {
                foreach (var o in source.Rows
                    .OfType<DataRow>()
                    .Select(i => new Class(i,this,IXclsS)))
                    {
                    m_clasI[o.OID] = o;
                    }
                },cancellation);
            }
        #endregion
        #region M:LoadEnum(CancellationToken,DataTable):Task
        private async Task LoadEnum(CancellationToken cancellation,DataTable source) {
            await Task.Delay(0,cancellation);
            await Task.Run(() => {
                foreach (var o in source.Rows
                    .OfType<DataRow>()
                    //.Where(i => i["LABEL"].ToString()=="def_log_level")
                    .Select(i => new PDBEnum(i,this,IXenuV)))
                    {
                    m_enuI[o.OID] = o;
                    }
                },cancellation);
            }
        #endregion
        #region M:LoadEntities(CancellationToken,DataTable):Task
        private async Task LoadEntities(CancellationToken cancellation,DataTable source) {
            await Task.Delay(0,cancellation);
            await Task.Run(() => {
                foreach (var o in source.Rows
                    .OfType<DataRow>()
                    .Select(i => new Entity(i,this)))
                    {
                    m_entI[o.OID] = o;
                    }
                },cancellation);
            }
        #endregion
        #region M:LoadInterfaces(CancellationToken,DataTable):Task
        private async Task LoadInterfaces(CancellationToken cancellation,DataTable source) {
            await Task.Delay(0,cancellation);
            await Task.Run(() => {
                foreach (var o in source.Rows
                    .OfType<DataRow>()
                    .Select(i => new Interface(i,this,IXintfI)))
                    {
                    m_intfI[o.OID] = o;
                    }
                },cancellation);
            }
        #endregion
        #region M:LoadReports(CancellationToken,DataTable):Task
        private async Task LoadReports(CancellationToken cancellation,DataTable source) {
            await Task.Delay(0,cancellation);
            await Task.Run(() => {
                foreach (var o in source.Rows
                    .OfType<DataRow>()
                    //.Where( i=> i["LABEL"].ToString() == "pr_time_spent_dep_order_opgroup_employee")
                    .Select(i => new Report(i,this)))
                    {
                    m_repoI[o.OID] = o;
                    }
                },cancellation);
            }
        #endregion
        #region M:LoadOperations(CancellationToken,DataTable):Task
        private async Task LoadOperations(CancellationToken cancellation,DataTable source) {
            await Task.Delay(0,cancellation);
            await Task.Run(() => {
                foreach (var o in source.Rows
                    .OfType<DataRow>()
                    .Select(i => new Operation(i,this)))
                    {
                    m_operI[o.OID] = o;
                    }
                },cancellation);
            }
        #endregion
        #region M:LoadViews(CancellationToken,DataTable):Task
        private async Task LoadViews(CancellationToken cancellation,DataTable source) {
            await Task.Delay(0,cancellation);
            await Task.Run(() => {
                foreach (var o in source.Rows
                    .OfType<DataRow>()
                    .Select(i => new View(i,this)))
                    {
                    m_viewI[o.OID] = o;
                    }
                },cancellation);
            }
        #endregion
        #region M:LoadUnits(CancellationToken,DataTable):Task
        private async Task LoadUnits(CancellationToken cancellation,DataTable source) {
            await Task.Delay(0,cancellation);
            await Task.Run(() => {
                foreach (var o in source.Rows
                    .OfType<DataRow>()
                    .Select(i => new Unit(i,this)))
                    {
                    m_DuniI[o.OID] = o;
                    }
                },cancellation);
            }
        #endregion
        #region M:LoadForms(CancellationToken,DataTable):Task
        private async Task LoadForms(CancellationToken cancellation,DataTable source) {
            await Task.Delay(0,cancellation);
            await Task.Run(() => {
                foreach (var o in source.Rows
                    .OfType<DataRow>()
                    .Select(i => new Form(i,this)))
                    {
                    m_formI[o.OID] = o;
                    }
                },cancellation);
            }
        #endregion
        #region M:LoadModules(CancellationToken,DataTable)
        private async Task LoadModules(CancellationToken cancellation,DataTable source) {
            await Task.Delay(0,cancellation);
            await Task.Run(() => {
                foreach (var row in source.Rows
                    .OfType<DataRow>()
                    .Select(i => new Module(i,this)))
                    {
                    lock(m_modI)
                        {
                        m_modI[row.OID] = row;
                        }
                    }
                },cancellation);
            }
        #endregion
        #region M:LoadQueries(CancellationToken,DataTable):Task
        private async Task LoadQueries(CancellationToken cancellation,DataTable source) {
            await Task.Delay(0,cancellation);
            await Task.Run(() => {
                foreach (var o in source.Rows
                    .OfType<DataRow>()
                    .Select(i => new Query(i,this)))
                    {
                    m_querI[o.OID] = o;
                    }
                },cancellation);
            }
        #endregion
        #region M:LoadStages(CancellationToken,DataTable):Task
        private async Task LoadStages(CancellationToken cancellation,DataTable source) {
            await Task.Delay(0,cancellation);
            await Task.Run(() => {
                foreach (var o in source.Rows
                    .OfType<DataRow>()
                    .Select(i => new Stage(i,this)))
                    {
                    m_stagI[o.OID] = o;
                    }
                },cancellation);
            }
        #endregion
        #region M:LoadSqlObjects(CancellationToken,DataTable):Task
        private async Task LoadSqlObjects(CancellationToken cancellation,DataTable source) {
            await Task.Delay(0,cancellation);
            foreach (var row in source.Rows
                .OfType<DataRow>()
                .Select(i => new MetadataRecord(i))
                .Where(i => (i.Type != SqlObjectType.None) && !String.IsNullOrWhiteSpace(i.Script) && !i.IsDisabled)
                .OrderBy(i=>i))
                {
                Merge(row.Type,row.Script);
                }
            }
        #endregion
        #region M:LoadSqlObjects(DataTable)
        private void LoadSqlObjects(DataTable source) {
            foreach (var row in source.Rows
                .OfType<DataRow>()
                .Select(i => new MetadataRecord(i))
                .Where(i => (i.Type != SqlObjectType.None) && !String.IsNullOrWhiteSpace(i.Script) && !i.IsDisabled)
                .OrderBy(i=>i))
                {
                Merge(row.Type,row.Script);
                }
            }
        #endregion
        #region M:LoadUsers(CancellationToken,DataTable):Task
        private async Task LoadUsers(CancellationToken cancellation,DataTable source) {
            await Task.Delay(0,cancellation);
            await Task.Run(() => {
                foreach (var row in source.Rows
                    .OfType<DataRow>()
                    .Select(i => new User(i,this)))
                    {
                    lock(m_usrI)
                        {
                        m_usrI[row.ID] = row;
                        }
                        }
                e_usrI.Set();
                });
            }
        #endregion
        #region M:LoadUsers(Byte[])
        private void LoadUsers(Byte[] source) {
            lock(m_usrI) {
                using (var memory = new MemoryStream(source)) {
                    using (var reader = new GZipStream(memory,CompressionMode.Decompress)) {
                        XDocument.Load(reader).Root
                            .Elements("User")
                            .Select(i => new User(i))
                            .ForEach(i => {
                                {
                                m_usrI[i.ID] = i;
                                }
                            });
                        }
                    }
                }
            return;
            }
        #endregion
        #region M:Merge(SqlObjectType,String)
        private void Merge(SqlObjectType type,String script)
            {
            Merge(type,(new SqlObjectScriptDecoder()).Decode(script));
            }
        #endregion
        #region M:Merge(SqlObjectType,IEnumerable<SqlScriptBatch>)
        private void Merge(SqlObjectType type,IEnumerable<SqlScriptBatch> source) {
            if ((type != SqlObjectType.None) && (type != SqlObjectType.ScriptAfter) && (type != SqlObjectType.ScriptBefore)) {
                Boolean? IsAnsiNullsOn = null;
                Boolean? IsQuotedIdentifier = null;
                SqlTable TargetTable = null;
                foreach (var statement in source.SelectMany(i => i.Statements)) {
                    var flag = false;
                    #region SET..
                    if (statement is SqlFragmentPredicateSetStatement PredicateSetStatement) {
                        if (PredicateSetStatement.Options.HasFlag(SetOptions.AnsiNulls))        { IsAnsiNullsOn        = true; continue; }
                        if (PredicateSetStatement.Options.HasFlag(SetOptions.QuotedIdentifier)) { IsQuotedIdentifier   = true; continue; }
                        }
                    #endregion
                    #region CREATE TABLE
                    if (statement is SqlScriptCreateTableStatement CreateTableStatement) {
                        TargetTable = new SqlTable(CreateTableStatement);
                        m_tbN[TargetTable.QualifiedName] = TargetTable;
                        continue;
                        }
                    #endregion
                    #region CREATE INDEX
                    if (statement is SqlScriptCreateIndexStatement index) {
                        if (m_tbN.TryGetValue(index.TargetObject,out var table)) {
                            if (table.Indexes.All(i => !i.Name.Equals(index.Name))) {
                                table.Indexes.Add(index);
                                }
                            }
                        continue;
                        }
                    #endregion
                    #region CREATE FUNCTION
                    if (statement is ISqlFunction function) {
                        m_fuN[function.Name] = function;
                        continue;
                        }
                    #endregion
                    #region CREATE PROCEDURE
                    if (statement is ISqlProcedure procedure) {
                        m_pcN[procedure.Name] = procedure;
                        continue;
                        }
                    #endregion
                    #region CREATE TRIGGER
                    if (statement is SqlScriptCreateTriggerStatement trigger) {
                        if (m_tbN.TryGetValue(trigger.TargetName,out var table)) {
                            if (table.Triggers.All(i => !i.Name.Equals(trigger.Name))) {
                                table.Triggers.Add(trigger);
                                }
                            }
                        continue;
                        }
                    #endregion
                    #region ALTER TABLE
                    if (statement is SqlFragmentAlterTableAddTableElementStatement altertable) {
                        foreach (var constraint in altertable.Definition.Constraints) {
                            if (m_tbN.TryGetValue(altertable.Name,out var table)) {
                                if (table.Constraints.All(i => !SqlIdentifier.Equals(i.Name,constraint.Name))) {
                                    table.Constraints.Add(constraint);
                                    }
                                }
                            }
                        continue;
                        }
                    #endregion
                    #region CREATE VIEW
                    if (statement is SqlScriptCreateViewStatement CreateViewStatement) {
                        var o = new SqlView(CreateViewStatement);
                        m_viN[o.QualifiedName] = o;
                        continue;
                        }
                    #endregion
                    #region CREATE ASSEMBLY
                    if (statement is SqlFragmentCreateAssemblyStatement CreateAssembly) {
                        m_asN[CreateAssembly.QualifiedName] = CreateAssembly;
                        continue;
                        }
                    #endregion
                    #region CREATE AGGREGATE
                    if (statement is SqlFragmentCreateAggregateStatement CreateAggregate) {
                        m_agN[CreateAggregate.QualifiedName] = CreateAggregate;
                        continue;
                        }
                    #endregion
                    #region EXECUTE...
                    if (statement is SqlScriptExecuteModuleStatement execute) {
                        #region [sp_addextendedproperty]
                        if (execute.Module.ObjectIdentifier == "sp_addextendedproperty") {
                            var names = new SortedDictionary<Int32,String>();
                            var types = new SortedDictionary<Int32,String>();
                            String name = null,value = null;
                            foreach (var argument in execute.Arguments) {
                                if (argument.Parameter.ToString() == "@name" ) { name  = argument.Value.ToString(); }
                                if (argument.Parameter.ToString() == "@value") { value = argument.Value.ToString(); }
                                if (IsMatch(argument.Parameter.ToString(),@"@level(\d+)(type|name)",out var match)) {
                                    var target = (match.Groups[2].Value == "type")
                                        ? types
                                        : names;
                                    target.Add(Int32.Parse(match.Groups[1].Value),argument.Value.ToString());
                                    }
                                }
                            var identifier = SqlObjectIdentifier.Create(names.Values.Select(i => new SqlIdentifier(i)));
                            var objectclass = SqlObjectClass.Default;
                            switch (types.Values.LastOrDefault()) {
                                case "AGGREGATE"             : { objectclass = SqlObjectClass.Aggregate;            } break;
                                case "ASSEMBLY"              : { objectclass = SqlObjectClass.Assembly;             } break;
                                case "COLUMN"                : { objectclass = SqlObjectClass.Column;               } break;
                                case "CONSTRAINT"            : { objectclass = SqlObjectClass.Constraint;           } break;
                                case "CONTRACT"              : { objectclass = SqlObjectClass.ServiceContract;      } break;
                                case "EVENT NOTIFICATION"    : { objectclass = SqlObjectClass.EventNotification;    } break;
                                case "FILEGROUP"             : { objectclass = SqlObjectClass.DatabaseFileGroup;    } break;
                                case "FUNCTION"              : { objectclass = SqlObjectClass.Function;             } break;
                                case "INDEX"                 : { objectclass = SqlObjectClass.Index;                } break;
                                case "LOGICAL FILE NAME"     : { objectclass = SqlObjectClass.LogicalFileName;      } break;
                                case "MESSAGE TYPE"          : { objectclass = SqlObjectClass.MessageType;          } break;
                                case "PARAMETER"             : { objectclass = SqlObjectClass.Parameter;            } break;
                                case "PARTITION FUNCTION"    : { objectclass = SqlObjectClass.PartitionFunction;    } break;
                                case "PARTITION SCHEME"      : { objectclass = SqlObjectClass.PartitionScheme;      } break;
                                case "PLAN GUIDE"            : { objectclass = SqlObjectClass.PlanGuide;            } break;
                                case "PROCEDURE"             : { objectclass = SqlObjectClass.Procedure;            } break;
                                case "QUEUE"                 : { objectclass = SqlObjectClass.Queue;                } break;
                                case "REMOTE SERVICE BINDING": { objectclass = SqlObjectClass.RemoteServiceBinding; } break;
                                case "ROUTE"                 : { objectclass = SqlObjectClass.ServiceRoute;         } break;
                                case "RULE"                  : { objectclass = SqlObjectClass.Rule;                 } break;
                                case "SCHEMA"                : { objectclass = SqlObjectClass.Schema;               } break;
                                case "SEQUENCE"              : { objectclass = SqlObjectClass.Sequence;             } break;
                                case "SERVICE"               : { objectclass = SqlObjectClass.Service;              } break;
                                case "SYNONYM"               : { objectclass = SqlObjectClass.Synonym;              } break;
                                case "TABLE"                 : { objectclass = SqlObjectClass.Table;                } break;
                                case "TRIGGER"               : { objectclass = SqlObjectClass.Trigger;              } break;
                                case "TYPE"                  : { objectclass = SqlObjectClass.UserDefinedType;      } break;
                                case "USER"                  : { objectclass = SqlObjectClass.User;                 } break;
                                case "VIEW"                  : { objectclass = SqlObjectClass.View;                 } break;
                                case "XML SCHEMA COLLECTION" : { objectclass = SqlObjectClass.XmlSchemaCollection;  } break;
                                }
                            m_properties[new SqlExtendedPropertyIdentity(objectclass,identifier,name)] = value;
                            continue;
                            }
                        #endregion
                        }
                    #endregion
                    throw new NotImplementedException();
                    }
                }
            }
        #endregion
        #region M:MakeFolderIfItNotExist(String)
        private static void MakeFolderIfItNotExist(String path) {
            if (!Directory.Exists(path)) {
                Directory.CreateDirectory(path);
                }
            }
        #endregion
        #region M:UpdateColumnDescription(String,String,String)
        private void UpdateColumnDescription(String TableName,String ColumnName,String Description) {
            var r = m_tbN[SqlObjectIdentifier.Parse(TableName)].Columns.FirstOrDefault(i => i.Name == ColumnName);
            if (r != null) {
                r.Description = Description;
                }
            }
        #endregion
        #region M:UpdateTableDescription(String,String)
        private void UpdateTableDescription(String TableName,String Description) {
            m_tbN[SqlObjectIdentifier.Parse(TableName)].Description = Description;
            }
        #endregion
        #region M:ISqlObjectResolver<SqlExtendedPropertyIdentity,String>.GetObject(SqlExtendedPropertyIdentity):String
        String ISqlObjectResolver<SqlExtendedPropertyIdentity,String>.GetObject(SqlExtendedPropertyIdentity key) {
            if (key == new SqlExtendedPropertyIdentity(SqlObjectClass.Index, SqlObjectIdentifier.Parse("[dbo].[MOBILE_PUSH_TOKENS].[IX_Table_DeviceID_UserName]"), "MS_Description"))
                {
                return @"Search on Device ID and UserName";
                }
            return m_properties.TryGetValue(key,out var r)
                ? r
                : null;
            }
        #endregion
        #region M:ISqlObjectResolver<Int32?,User>.GetObject(Int32):User
        User ISqlObjectResolver<Int32?,User>.GetObject(Int32? key) {
            if (key == null) { return null; }
            e_usrI.WaitOne();
            return m_usrI.TryGetValue(key.Value,out var r)
                ? r
                : null;
            }
        #endregion
        #region M:ISqlObjectResolver<Int32?,Module>.GetObject(Int32):Module
        Module ISqlObjectResolver<Int32?,Module>.GetObject(Int32? key) {
            if (key == null) { return null; }
            return m_modI.TryGetValue(key.Value,out var r)
                ? r
                : null;
            }
        #endregion
        #region M:ISqlObjectResolver<Int32?,Unit>.GetObject(Int32):Unit
        Unit ISqlObjectResolver<Int32?,Unit>.GetObject(Int32? key) {
            if (key == null) { return null; }
            return m_DuniI.TryGetValue(key.Value,out var r)
                ? r
                : null;
            }
        #endregion
        #region M:ISqlObjectResolver<Int32?,Entity>.GetObject(Int32):Entity
        Entity ISqlObjectResolver<Int32?,Entity>.GetObject(Int32? key) {
            if (key == null) { return null; }
            return m_entI.TryGetValue(key.Value,out var r)
                ? r
                : null;
            }
        #endregion
        #region M:ISqlObjectResolver<Int32?,Class>.GetObject(Int32):Class
        Class ISqlObjectResolver<Int32?,Class>.GetObject(Int32? key) {
            if (key == null) { return null; }
            return m_clasI.TryGetValue(key.Value,out var r)
                ? r
                : null;
            }
        #endregion
        #region M:ISqlObjectResolver<Int32?,Query>.GetObject(Int32):Query
        Query ISqlObjectResolver<Int32?,Query>.GetObject(Int32? key) {
            if (key == null) { return null; }
            return m_querI.TryGetValue(key.Value,out var r)
                ? r
                : null;
            }
        #endregion
        #region M:ISqlObjectResolver<Int32?,Interface>.GetObject(Int32):Interface
        Interface ISqlObjectResolver<Int32?,Interface>.GetObject(Int32? key) {
            if (key == null) { return null; }
            return m_intfI.TryGetValue(key.Value,out var r)
                ? r
                : null;
            }
        #endregion
        #region M:ISqlObjectResolver<Int32?,Report>.GetObject(Int32):Report
        Report ISqlObjectResolver<Int32?,Report>.GetObject(Int32? key) {
            if (key == null) { return null; }
            return m_repoI.TryGetValue(key.Value,out var r)
                ? r
                : null;
            }
        #endregion
        #region M:ISqlObjectResolver<Int32?,View>.GetObject(Int32):View
        View ISqlObjectResolver<Int32?,View>.GetObject(Int32? key) {
            if (key == null) { return null; }
            return m_viewI.TryGetValue(key.Value,out var r)
                ? r
                : null;
            }
        #endregion
        #region M:ISqlObjectResolver<Int32?,Operation>.GetObject(Int32):Operation
        Operation ISqlObjectResolver<Int32?,Operation>.GetObject(Int32? key) {
            if (key == null) { return null; }
            return m_operI.TryGetValue(key.Value,out var r)
                ? r
                : null;
            }
        #endregion
        #region M:ISqlObjectResolver<Int32?,ClassState>.GetObject(Int32):ClassState
        ClassState ISqlObjectResolver<Int32?,ClassState>.GetObject(Int32? key) {
            if (key == null) { return null; }
            return m_clssI.TryGetValue(key.Value,out var r)
                ? r
                : null;
            }
        #endregion
        #region M:GetService(Type):Object
        /// <summary>Gets the service object of the specified type.</summary>
        /// <param name="service">An object that specifies the type of service object to get.</param>
        /// <returns>A service object of type <paramref name="service"/>.
        /// -or-
        /// <see langword="null"/> if there is no service object of type <paramref name="service"/>.</returns>
        protected override Object GetService(Type service) {
            if (service == typeof(ISqlExtendedPropertyResolver)) { return this; }
            if (service.IsAssignableFrom(GetType())) { return this; }
            //if (service == typeof(ISqlObjectResolver<Int32?,PDBUser>)) { return this; }
            //if (service == typeof(ISqlObjectResolver<Int32?,Module>))  { return this; }
            //if (service == typeof(ISqlObjectResolver<Int32?,Unit>))    { return this; }
            //if (service == typeof(ISqlObjectResolver<Int32?,Entity>))  { return this; }
            //if (service == typeof(ISqlObjectResolver<Int32?,Query>))   { return this; }
            //if (service == typeof(ISqlObjectResolver<Int32?,Class>))   { return this; }
            //if (service == typeof(ISqlObjectResolver<Int32?,Report>))  { return this; }
            //if (service == typeof(ISqlObjectResolver<Int32?,View>))    { return this; }
            return base.GetService(service);
            }
        #endregion
        #region M:BuildIndex(CancellationToken,DataTable,IDictionary<Int32,IList<DataRow>>,String):Task
        private async Task BuildIndex(CancellationToken cancellation,DataTable source,IDictionary<Int32,IList<DataRow>> target,String column) {
            await Task.Delay(0,cancellation);
            if (source != null) {
                foreach (DataRow r in source.Rows) {
                    var i = PropSI4(r[column],0);
                    if (i != 0) {
                        if (!target.TryGetValue(i, out var rows)) {
                            target.Add(i,rows = new List<DataRow>());
                            }
                        rows.Add(r);
                        }
                    }
                }
            }
        #endregion
        #region M:BuildIndex(CancellationToken,DataTable,IDictionary<Int32,IList<DataRow>>,String,Func<DataRow,T>):Task
        private async Task BuildIndex<T>(CancellationToken cancellation,DataTable source,IDictionary<Int32,IList<T>> target,String column,Func<DataRow,T> predicate) {
            if (predicate == null) { throw new ArgumentNullException(nameof(predicate)); }
            await Task.Delay(0,cancellation);
            if (source != null) {
                foreach (DataRow r in source.Rows) {
                    var i = PropSI4(r[column],0);
                    if (i != 0) {
                        if (!target.TryGetValue(i, out var rows)) {
                            target.Add(i,rows = new List<T>());
                            }
                        var o = predicate(r);
                        rows.Add(o);
                        }
                    }
                }
            }
        #endregion
        #region M:LoadClassState(DataRow):ClassState
        private ClassState LoadClassState(DataRow source) {
            var r = new ClassState(source,this);
            m_clssI.Add(r.OID,r);
            return r;
            }
        #endregion

        private class MetadataRecord : SqlObject,IComparable<MetadataRecord>
            {
            [UsedImplicitly][SqlObjectFieldMapping(Source = "NAME")]     public String Name { get; }
            [UsedImplicitly][SqlObjectFieldMapping(Source = "SQLTEXT")]  public String Script { get; }
            [UsedImplicitly][SqlObjectFieldMapping(Source = "OID")]      public Int32 OID { get; }
            [UsedImplicitly][SqlObjectFieldMapping(Source = "MTYPE")]    public SqlObjectType Type { get; }
            [UsedImplicitly][SqlObjectFieldMapping(Source = "DISABLED")] public Boolean IsDisabled { get; }

            #region ctor{DataRow}
            public MetadataRecord(DataRow row)
                : base(null,row)
                {
                return;
                }
            #endregion
            #region M:CompareTo(MetadataRecord):Int32
            public Int32 CompareTo(MetadataRecord other) {
                if (ReferenceEquals(other,null)) { return 1; }
                if (ReferenceEquals(other,this)) { return 0; }
                if (other.Type == Type) { return Name.CompareTo(other.Name); }
                return values[PropSI4((Int16)(Int32)other.Type,(Int16)(Int32)Type)];
                }
            #endregion
            #region M:ToString:String
            public override String ToString()
                {
                return $"{{{Type}}}:{{{Name}}}";
                }
            #endregion

            #region values
            private static readonly IDictionary<Int32,Int32> values = new Dictionary<Int32,Int32> {
                /* None:ScriptBefore                      */ { 0x0000000a,-1},
                /* None:Table                             */ { 0x00000014,-1},
                /* None:Function                          */ { 0x0000001e,-1},
                /* None:Procedure                         */ { 0x00000028,-1},
                /* None:Index                             */ { 0x00000032,-1},
                /* None:Trigger                           */ { 0x0000003c,-1},
                /* None:ForeignKeyConstraint              */ { 0x00000046,-1},
                /* None:View                              */ { 0x00000050,-1},
                /* None:CheckConstraint                   */ { 0x0000005a,-1},
                /* None:Statistics                        */ { 0x00000064,-1},
                /* None:Assembly                          */ { 0x000000c8,-1},
                /* None:TableType                         */ { 0x000000d2,-1},
                /* None:PartitionFunction                 */ { 0x000000dc,-1},
                /* None:PartitionScheme                   */ { 0x000000e6,-1},
                /* None:ScriptAfter                       */ { 0x000003e8,-1},
                /* ScriptBefore:None                      */ { 0x000a0000,+1},
                /* ScriptBefore:Table                     */ { 0x000a0014,-1},
                /* ScriptBefore:Function                  */ { 0x000a001e,-1},
                /* ScriptBefore:Procedure                 */ { 0x000a0028,-1},
                /* ScriptBefore:Index                     */ { 0x000a0032,-1},
                /* ScriptBefore:Trigger                   */ { 0x000a003c,-1},
                /* ScriptBefore:ForeignKeyConstraint      */ { 0x000a0046,-1},
                /* ScriptBefore:View                      */ { 0x000a0050,-1},
                /* ScriptBefore:CheckConstraint           */ { 0x000a005a,-1},
                /* ScriptBefore:Statistics                */ { 0x000a0064,-1},
                /* ScriptBefore:Assembly                  */ { 0x000a00c8,-1},
                /* ScriptBefore:TableType                 */ { 0x000a00d2,-1},
                /* ScriptBefore:PartitionFunction         */ { 0x000a00dc,-1},
                /* ScriptBefore:PartitionScheme           */ { 0x000a00e6,-1},
                /* ScriptBefore:ScriptAfter               */ { 0x000a03e8,-1},
                /* Table:None                             */ { 0x00140000,+1},
                /* Table:ScriptBefore                     */ { 0x0014000a,+1},
                /* Table:Function                         */ { 0x0014001e,+1},
                /* Table:Procedure                        */ { 0x00140028,+1},
                /* Table:Index                            */ { 0x00140032,+1},
                /* Table:Trigger                          */ { 0x0014003c,+1},
                /* Table:ForeignKeyConstraint             */ { 0x00140046,+1},
                /* Table:View                             */ { 0x00140050,+1},
                /* Table:CheckConstraint                  */ { 0x0014005a,+1},
                /* Table:Statistics                       */ { 0x00140064,+1},
                /* Table:Assembly                         */ { 0x001400c8,+1},
                /* Table:TableType                        */ { 0x001400d2,+1},
                /* Table:PartitionFunction                */ { 0x001400dc,+1},
                /* Table:PartitionScheme                  */ { 0x001400e6,+1},
                /* Table:ScriptAfter                      */ { 0x001403e8,+1},
                /* Function:None                          */ { 0x001e0000,+1},
                /* Function:ScriptBefore                  */ { 0x001e000a,+1},
                /* Function:Table                         */ { 0x001e0014,-1},
                /* Function:Procedure                     */ { 0x001e0028,+1},
                /* Function:Index                         */ { 0x001e0032,-1},
                /* Function:Trigger                       */ { 0x001e003c,-1},
                /* Function:ForeignKeyConstraint          */ { 0x001e0046,-1},
                /* Function:View                          */ { 0x001e0050,-1},
                /* Function:CheckConstraint               */ { 0x001e005a,-1},
                /* Function:Statistics                    */ { 0x001e0064,-1},
                /* Function:Assembly                      */ { 0x001e00c8,-1},
                /* Function:TableType                     */ { 0x001e00d2,-1},
                /* Function:PartitionFunction             */ { 0x001e00dc,-1},
                /* Function:PartitionScheme               */ { 0x001e00e6,-1},
                /* Function:ScriptAfter                   */ { 0x001e03e8,+1},
                /* Procedure:None                         */ { 0x00280000,+1},
                /* Procedure:ScriptBefore                 */ { 0x0028000a,+1},
                /* Procedure:Table                        */ { 0x00280014,-1},
                /* Procedure:Function                     */ { 0x0028001e,-1},
                /* Procedure:Index                        */ { 0x00280032,-1},
                /* Procedure:Trigger                      */ { 0x0028003c,-1},
                /* Procedure:ForeignKeyConstraint         */ { 0x00280046,-1},
                /* Procedure:View                         */ { 0x00280050,-1},
                /* Procedure:CheckConstraint              */ { 0x0028005a,-1},
                /* Procedure:Statistics                   */ { 0x00280064,-1},
                /* Procedure:Assembly                     */ { 0x002800c8,-1},
                /* Procedure:TableType                    */ { 0x002800d2,-1},
                /* Procedure:PartitionFunction            */ { 0x002800dc,-1},
                /* Procedure:PartitionScheme              */ { 0x002800e6,-1},
                /* Procedure:ScriptAfter                  */ { 0x002803e8,+1},
                /* Index:None                             */ { 0x00320000,+1},
                /* Index:ScriptBefore                     */ { 0x0032000a,+1},
                /* Index:Table                            */ { 0x00320014,-1},
                /* Index:Function                         */ { 0x0032001e,+1},
                /* Index:Procedure                        */ { 0x00320028,+1},
                /* Index:Trigger                          */ { 0x0032003c,-1},
                /* Index:ForeignKeyConstraint             */ { 0x00320046,-1},
                /* Index:View                             */ { 0x00320050,-1},
                /* Index:CheckConstraint                  */ { 0x0032005a,-1},
                /* Index:Statistics                       */ { 0x00320064,-1},
                /* Index:Assembly                         */ { 0x003200c8,-1},
                /* Index:TableType                        */ { 0x003200d2,-1},
                /* Index:PartitionFunction                */ { 0x003200dc,-1},
                /* Index:PartitionScheme                  */ { 0x003200e6,-1},
                /* Index:ScriptAfter                      */ { 0x003203e8,+1},
                /* Trigger:None                           */ { 0x003c0000,-1},
                /* Trigger:ScriptBefore                   */ { 0x003c000a,-1},
                /* Trigger:Table                          */ { 0x003c0014,-1},
                /* Trigger:Function                       */ { 0x003c001e,+1},
                /* Trigger:Procedure                      */ { 0x003c0028,+1},
                /* Trigger:Index                          */ { 0x003c0032,-1},
                /* Trigger:ForeignKeyConstraint           */ { 0x003c0046,-1},
                /* Trigger:View                           */ { 0x003c0050,-1},
                /* Trigger:CheckConstraint                */ { 0x003c005a,-1},
                /* Trigger:Statistics                     */ { 0x003c0064,-1},
                /* Trigger:Assembly                       */ { 0x003c00c8,-1},
                /* Trigger:TableType                      */ { 0x003c00d2,-1},
                /* Trigger:PartitionFunction              */ { 0x003c00dc,-1},
                /* Trigger:PartitionScheme                */ { 0x003c00e6,-1},
                /* Trigger:ScriptAfter                    */ { 0x003c03e8,+1},
                /* ForeignKeyConstraint:None              */ { 0x00460000,+1},
                /* ForeignKeyConstraint:ScriptBefore      */ { 0x0046000a,+1},
                /* ForeignKeyConstraint:Table             */ { 0x00460014,-1},
                /* ForeignKeyConstraint:Function          */ { 0x0046001e,+1},
                /* ForeignKeyConstraint:Procedure         */ { 0x00460028,+1},
                /* ForeignKeyConstraint:Index             */ { 0x00460032,+1},
                /* ForeignKeyConstraint:Trigger           */ { 0x0046003c,-1},
                /* ForeignKeyConstraint:View              */ { 0x00460050,-1},
                /* ForeignKeyConstraint:CheckConstraint   */ { 0x0046005a,-1},
                /* ForeignKeyConstraint:Statistics        */ { 0x00460064,+1},
                /* ForeignKeyConstraint:Assembly          */ { 0x004600c8,+1},
                /* ForeignKeyConstraint:TableType         */ { 0x004600d2,+1},
                /* ForeignKeyConstraint:PartitionFunction */ { 0x004600dc,+1},
                /* ForeignKeyConstraint:PartitionScheme   */ { 0x004600e6,+1},
                /* ForeignKeyConstraint:ScriptAfter       */ { 0x004603e8,+1},
                /* View:None                              */ { 0x00500000,+1},
                /* View:ScriptBefore                      */ { 0x0050000a,+1},
                /* View:Table                             */ { 0x00500014,-1},
                /* View:Function                          */ { 0x0050001e,+1},
                /* View:Procedure                         */ { 0x00500028,+1},
                /* View:Index                             */ { 0x00500032,+1},
                /* View:Trigger                           */ { 0x0050003c,+1},
                /* View:ForeignKeyConstraint              */ { 0x00500046,+1},
                /* View:CheckConstraint                   */ { 0x0050005a,+1},
                /* View:Statistics                        */ { 0x00500064,+1},
                /* View:Assembly                          */ { 0x005000c8,+1},
                /* View:TableType                         */ { 0x005000d2,+1},
                /* View:PartitionFunction                 */ { 0x005000dc,+1},
                /* View:PartitionScheme                   */ { 0x005000e6,+1},
                /* View:ScriptAfter                       */ { 0x005003e8,+1},
                /* CheckConstraint:None                   */ { 0x005a0000,+1},
                /* CheckConstraint:ScriptBefore           */ { 0x005a000a,+1},
                /* CheckConstraint:Table                  */ { 0x005a0014,-1},
                /* CheckConstraint:Function               */ { 0x005a001e,+1},
                /* CheckConstraint:Procedure              */ { 0x005a0028,+1},
                /* CheckConstraint:Index                  */ { 0x005a0032,+1},
                /* CheckConstraint:Trigger                */ { 0x005a003c,+1},
                /* CheckConstraint:ForeignKeyConstraint   */ { 0x005a0046,+1},
                /* CheckConstraint:View                   */ { 0x005a0050,-1},
                /* CheckConstraint:Statistics             */ { 0x005a0064,+1},
                /* CheckConstraint:Assembly               */ { 0x005a00c8,+1},
                /* CheckConstraint:TableType              */ { 0x005a00d2,+1},
                /* CheckConstraint:PartitionFunction      */ { 0x005a00dc,+1},
                /* CheckConstraint:PartitionScheme        */ { 0x005a00e6,+1},
                /* CheckConstraint:ScriptAfter            */ { 0x005a03e8,+1},
                /* Statistics:None                        */ { 0x00640000,+1},
                /* Statistics:ScriptBefore                */ { 0x0064000a,+1},
                /* Statistics:Table                       */ { 0x00640014,-1},
                /* Statistics:Function                    */ { 0x0064001e,-1},
                /* Statistics:Procedure                   */ { 0x00640028,-1},
                /* Statistics:Index                       */ { 0x00640032,-1},
                /* Statistics:Trigger                     */ { 0x0064003c,-1},
                /* Statistics:ForeignKeyConstraint        */ { 0x00640046,-1},
                /* Statistics:View                        */ { 0x00640050,-1},
                /* Statistics:CheckConstraint             */ { 0x0064005a,-1},
                /* Statistics:Assembly                    */ { 0x006400c8,-1},
                /* Statistics:TableType                   */ { 0x006400d2,-1},
                /* Statistics:PartitionFunction           */ { 0x006400dc,-1},
                /* Statistics:PartitionScheme             */ { 0x006400e6,-1},
                /* Statistics:ScriptAfter                 */ { 0x006403e8,+1},
                /* Assembly:None                          */ { 0x00c80000,+1},
                /* Assembly:ScriptBefore                  */ { 0x00c8000a,+1},
                /* Assembly:Table                         */ { 0x00c80014,-1},
                /* Assembly:Function                      */ { 0x00c8001e,+1},
                /* Assembly:Procedure                     */ { 0x00c80028,+1},
                /* Assembly:Index                         */ { 0x00c80032,-1},
                /* Assembly:Trigger                       */ { 0x00c8003c,-1},
                /* Assembly:ForeignKeyConstraint          */ { 0x00c80046,-1},
                /* Assembly:View                          */ { 0x00c80050,-1},
                /* Assembly:CheckConstraint               */ { 0x00c8005a,-1},
                /* Assembly:Statistics                    */ { 0x00c80064,+1},
                /* Assembly:TableType                     */ { 0x00c800d2,+1},
                /* Assembly:PartitionFunction             */ { 0x00c800dc,+1},
                /* Assembly:PartitionScheme               */ { 0x00c800e6,+1},
                /* Assembly:ScriptAfter                   */ { 0x00c803e8,+1},
                /* TableType:None                         */ { 0x00d20000,+1},
                /* TableType:ScriptBefore                 */ { 0x00d2000a,+1},
                /* TableType:Table                        */ { 0x00d20014,-1},
                /* TableType:Function                     */ { 0x00d2001e,+1},
                /* TableType:Procedure                    */ { 0x00d20028,+1},
                /* TableType:Index                        */ { 0x00d20032,-1},
                /* TableType:Trigger                      */ { 0x00d2003c,-1},
                /* TableType:ForeignKeyConstraint         */ { 0x00d20046,-1},
                /* TableType:View                         */ { 0x00d20050,-1},
                /* TableType:CheckConstraint              */ { 0x00d2005a,-1},
                /* TableType:Statistics                   */ { 0x00d20064,-1},
                /* TableType:Assembly                     */ { 0x00d200c8,-1},
                /* TableType:PartitionFunction            */ { 0x00d200dc,-1},
                /* TableType:PartitionScheme              */ { 0x00d200e6,-1},
                /* TableType:ScriptAfter                  */ { 0x00d203e8,+1},
                /* PartitionFunction:None                 */ { 0x00dc0000,+1},
                /* PartitionFunction:ScriptBefore         */ { 0x00dc000a,+1},
                /* PartitionFunction:Table                */ { 0x00dc0014,-1},
                /* PartitionFunction:Function             */ { 0x00dc001e,-1},
                /* PartitionFunction:Procedure            */ { 0x00dc0028,-1},
                /* PartitionFunction:Index                */ { 0x00dc0032,-1},
                /* PartitionFunction:Trigger              */ { 0x00dc003c,-1},
                /* PartitionFunction:ForeignKeyConstraint */ { 0x00dc0046,-1},
                /* PartitionFunction:View                 */ { 0x00dc0050,-1},
                /* PartitionFunction:CheckConstraint      */ { 0x00dc005a,-1},
                /* PartitionFunction:Statistics           */ { 0x00dc0064,-1},
                /* PartitionFunction:Assembly             */ { 0x00dc00c8,-1},
                /* PartitionFunction:TableType            */ { 0x00dc00d2,-1},
                /* PartitionFunction:PartitionScheme      */ { 0x00dc00e6,-1},
                /* PartitionFunction:ScriptAfter          */ { 0x00dc03e8,+1},
                /* PartitionScheme:None                   */ { 0x00e60000,+1},
                /* PartitionScheme:ScriptBefore           */ { 0x00e6000a,+1},
                /* PartitionScheme:Table                  */ { 0x00e60014,-1},
                /* PartitionScheme:Function               */ { 0x00e6001e,-1},
                /* PartitionScheme:Procedure              */ { 0x00e60028,-1},
                /* PartitionScheme:Index                  */ { 0x00e60032,-1},
                /* PartitionScheme:Trigger                */ { 0x00e6003c,-1},
                /* PartitionScheme:ForeignKeyConstraint   */ { 0x00e60046,-1},
                /* PartitionScheme:View                   */ { 0x00e60050,-1},
                /* PartitionScheme:CheckConstraint        */ { 0x00e6005a,-1},
                /* PartitionScheme:Statistics             */ { 0x00e60064,-1},
                /* PartitionScheme:Assembly               */ { 0x00e600c8,-1},
                /* PartitionScheme:TableType              */ { 0x00e600d2,-1},
                /* PartitionScheme:PartitionFunction      */ { 0x00e600dc,-1},
                /* PartitionScheme:ScriptAfter            */ { 0x00e603e8,+1},
                /* ScriptAfter:None                       */ { 0x03e80000,+1},
                /* ScriptAfter:ScriptBefore               */ { 0x03e8000a,+1},
                /* ScriptAfter:Table                      */ { 0x03e80014,-1},
                /* ScriptAfter:Function                   */ { 0x03e8001e,-1},
                /* ScriptAfter:Procedure                  */ { 0x03e80028,-1},
                /* ScriptAfter:Index                      */ { 0x03e80032,-1},
                /* ScriptAfter:Trigger                    */ { 0x03e8003c,-1},
                /* ScriptAfter:ForeignKeyConstraint       */ { 0x03e80046,-1},
                /* ScriptAfter:View                       */ { 0x03e80050,-1},
                /* ScriptAfter:CheckConstraint            */ { 0x03e8005a,-1},
                /* ScriptAfter:Statistics                 */ { 0x03e80064,-1},
                /* ScriptAfter:Assembly                   */ { 0x03e800c8,-1},
                /* ScriptAfter:TableType                  */ { 0x03e800d2,-1},
                /* ScriptAfter:PartitionFunction          */ { 0x03e800dc,-1},
                /* ScriptAfter:PartitionScheme            */ { 0x03e800e6,-1},
                };
            #endregion
            }

        private readonly IDictionary<SqlObjectIdentifier,SqlTable> m_tbN = new SortedDictionary<SqlObjectIdentifier,SqlTable>();
        private readonly IDictionary<SqlObjectIdentifier,SqlView>  m_viN = new SortedDictionary<SqlObjectIdentifier,SqlView>();
        private readonly IDictionary<SqlObjectIdentifier,ISqlFunction>  m_fuN = new SortedDictionary<SqlObjectIdentifier,ISqlFunction>();
        private readonly IDictionary<SqlObjectIdentifier,ISqlProcedure> m_pcN = new SortedDictionary<SqlObjectIdentifier,ISqlProcedure>();
        private readonly IDictionary<SqlObjectIdentifier,ISqlAssembly>  m_asN = new SortedDictionary<SqlObjectIdentifier,ISqlAssembly>();
        private readonly IDictionary<SqlObjectIdentifier,ISqlAggregate>  m_agN = new SortedDictionary<SqlObjectIdentifier,ISqlAggregate>();
        private readonly IDictionary<SqlExtendedPropertyIdentity,String> m_properties = new SortedDictionary<SqlExtendedPropertyIdentity,String>();
        private readonly IDictionary<Int32,User>   m_usrI = new SortedDictionary<Int32,User>();
        private readonly IDictionary<Int32,Module> m_modI = new SortedDictionary<Int32,Module>();
        private readonly IDictionary<Int32,PDBEnum>   m_enuI = new SortedDictionary<Int32,PDBEnum>();
        private readonly IDictionary<Int32,Entity> m_entI = new SortedDictionary<Int32,Entity>();
        private readonly IDictionary<Int32,Unit> m_DuniI = new SortedDictionary<Int32,Unit>();
        private readonly IDictionary<Int32,Form> m_formI = new SortedDictionary<Int32,Form>();
        private readonly IDictionary<Int32,Query>    m_querI = new SortedDictionary<Int32,Query>();
        private readonly IDictionary<Int32,Stage>    m_stagI = new SortedDictionary<Int32,Stage>();
        private readonly IDictionary<Int32,Class>    m_clasI = new SortedDictionary<Int32,Class>();
        private readonly IDictionary<Int32,Interface> m_intfI = new SortedDictionary<Int32,Interface>();
        private readonly IDictionary<Int32,Report> m_repoI = new SortedDictionary<Int32,Report>();
        private readonly IDictionary<Int32,View> m_viewI = new SortedDictionary<Int32,View>();
        private readonly IDictionary<Int32,Operation> m_operI = new SortedDictionary<Int32,Operation>();
        private readonly IDictionary<Int32,ClassState> m_clssI = new SortedDictionary<Int32,ClassState>();
        private readonly ManualResetEvent e_usrI = new ManualResetEvent(false);
        [DebuggerBrowsable(DebuggerBrowsableState.Never)] internal readonly IDictionary<Int32,IList<DataRow>> IXenfI = new Dictionary<Int32,IList<DataRow>>();
        [DebuggerBrowsable(DebuggerBrowsableState.Never)] internal readonly IDictionary<Int32,IList<DataRow>> IXenuV = new Dictionary<Int32,IList<DataRow>>();
        [DebuggerBrowsable(DebuggerBrowsableState.Never)] internal readonly IDictionary<Int32,IList<ClassState>> IXclsS = new Dictionary<Int32,IList<ClassState>>();
        [DebuggerBrowsable(DebuggerBrowsableState.Never)] private readonly IDictionary<Int32,IList<DataRow>> IXintfI = new Dictionary<Int32,IList<DataRow>>();
        }
    }