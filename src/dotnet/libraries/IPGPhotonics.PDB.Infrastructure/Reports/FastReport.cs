using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    [FastReportClass("A2Report")]
    internal sealed class FastReport : Base
        {
        private String ClassName { get;set; }
        [UsedImplicitly][Field(Order=1000202)] public FastReportLanguage ScriptLanguage { get; }
        [UsedImplicitly][Field("ReportInfo.Name",Order=1000215)] public override String Name { get; }
        [UsedImplicitly][Field("ReportInfo.Created",Order=1000219)] public DateTime?  CreatedDate { get; }
        [UsedImplicitly][Field("ReportInfo.Modified",Order=1000220)] public DateTime? ModifiedDate { get; }
        [UsedImplicitly][Field("ReportInfo.Author",Order=1000216)] public String CreatedBy { get; }
        [UsedImplicitly][Field("ReportInfo.CreatorVersion",Order=1000221,Converter=typeof(SqlVersionConverter))] public Version CreatedVersion { get; }
        [UsedImplicitly][Field(Order=1000205)] public Boolean DoublePass { get; }
        [UsedImplicitly][Field(Order=1000206)] public Boolean Compressed { get; }
        [UsedImplicitly][Field(Order=1000204)][DefaultValue(true)] public Boolean ConvertNulls { get; } = true;
        [UsedImplicitly][Field(Order=1000200)][DefaultValue(true)] public Boolean StoreInResources { get; } = true;
        [UsedImplicitly][Field(Order=1000200)][DefaultValue(true)] public Boolean AutoFillDataSet { get; } = true;
        [UsedImplicitly][Field(Order=1000209)] public Boolean SmoothGraphics { get; }
        [UsedImplicitly][Field(Order=1000207)] public Boolean UseFileCache { get; }
        [UsedImplicitly][Field(Order=1000213)] public String StartReportEvent { get; }
        [UsedImplicitly][Field(Order=1000214)] public String FinishReportEvent { get; }
        [UsedImplicitly][Field(Order=1000210)] public String Password { get; }
        [UsedImplicitly][Field(Order=1000201)] public String BaseReport { get; }
        [UsedImplicitly][Field(Order=1000208)] public TextQuality TextQuality { get; }
        [UsedImplicitly][Field(Order=1000203,Converter=typeof(SqlStringCollectionConverter),ConverterParameter="StringSplitOptions=RemoveEmptyEntries;StringSplitSeparator={\r\n;\r;\n}")] public IList<String> ReferencedAssemblies { get; }
        [UsedImplicitly][Field(Order=1000212)] public Int32 MaxPages { get; }
        [UsedImplicitly][Field(Order=1000211)][DefaultValue(1)] public Int32 InitialPageNumber { get; } = 1;
        public String Script { get;private set; }
        public IList<DataConnectionBase> DataSources { get; } = new SqlObjectCollection<DataConnectionBase>();
        public IList<FastReportParameter> Parameters { get; } = new SqlObjectCollection<FastReportParameter>();
        public IList<PageBase> Pages { get; } = new SqlObjectCollection<PageBase>();
        public IList<Style> Styles { get; } = new SqlObjectCollection<Style>();
        public IList<Relation> Relations { get; } = new SqlObjectCollection<Relation>();
        public IList<Total> Totals { get; } = new SqlObjectCollection<Total>();

        public override IEnumerable<FastReportObject> Children { get {
            foreach (var o in Pages) {
                yield return o;
                }
            }}

        #region ctor
        private FastReport()
            {
            }
        #endregion
        #region M:LoadFrom(Byte[]):FastReport
        /// <summary>Loads a <see cref="FastReport"/> instance from the specified byte array containing report data.</summary>
        /// <param name="source">A byte array that contains the serialized report data to load. Cannot be <see langword="null"/>.</param>
        /// <returns>A <see cref="FastReport"/> instance created from the provided byte array.</returns>
        /// <exception cref="ArgumentNullException">Thrown if <paramref name="source"/> is <see langword="null"/>.</exception>
        public static FastReport LoadFrom(Byte[] source) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            using (var stream = new MemoryStream(source)) {
                return LoadFrom(stream);
                }
            }
        #endregion
        #region M:LoadFrom(Stream):FastReport
        /// <summary>Loads a <see cref="FastReport"/> object from the specified stream containing report data in XML format.</summary>
        /// <param name="source">The stream from which to read the report data. The stream must be readable and contain a valid FastReport XML document.</param>
        /// <returns>A <see cref="FastReport"/> object deserialized from the provided stream.</returns>
        /// <exception cref="ArgumentNullException">Thrown if the source stream is <see langword="null"/>.</exception>
        public static FastReport LoadFrom(Stream source) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            using (var reader = new XmlTextReader(source) {
                Normalization = false
                })
                {
                return LoadFrom(reader);
                }
            }
        #endregion
        #region M:LoadFrom(XmlReader):FastReport
        /// <summary>Loads a <see cref="FastReport"/> instance from the specified XML source.</summary>
        /// <param name="source">An <see cref="T:System.Xml.XmlReader"/> that provides the XML data for the report. Cannot be <see langword="null"/>.</param>
        /// <returns>A <see cref="FastReport"/> object initialized with the data read from the specified XML source.</returns>
        /// <exception cref="ArgumentNullException">Thrown if the source parameter is <see langword="null"/>.</exception>
        public static FastReport LoadFrom(XmlReader source) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            var r = new FastReport();
            r.ReadXml(source);
            return r;
            }
        #endregion
        #region M:ReadXmlA(XmlReader)
        protected override void ReadXmlA(XmlReader reader) {
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            while (reader.MoveToNextAttribute()) {
                switch (reader.LocalName) {
                    default:
                        ResolveFieldMappings(GetType(),out var mapping);
                        if (!mapping.TryGetValue(reader.LocalName, out var mi)) {
                            continue;
                            throw new NotSupportedException(
                                (reader is IXmlLineInfo LineInfo)
                                ? $@"[Line={LineInfo.LineNumber}] @Attribute=""{reader.LocalName}"" is not supported for ""{GetType().FullName}""."
                                : $@"@Attribute=""{reader.LocalName}"" is not supported for ""{GetType().FullName}""."
                                );
                            }
                        SetValue(mi,reader.Value);
                        break;
                    }
                }
            }
        #endregion
        #region M:ReadXmlE(XmlReader)
        protected override void ReadXmlE(XmlReader reader) {
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            ClassName = reader.LocalName;
            ResolveFieldMappings(GetType(),out var mapping);
            var objects = new List<FastReportObject>();
            ForEachE(reader,(_)=>{
                if (mapping.TryGetValue(reader.Name,out var pi)) {
                    if (IsGenericCollection(pi.PropertyType,out var TypeG,out var TypeE)){
                        var target = (IList)Activator.CreateInstance(typeof(List<>).MakeGenericType(TypeE));
                        using (var r = reader.ReadSubtree()) {
                            r.MoveToContent();
                            ForEachE(r,CreateE);
                            }
                        target = (IList)Activator.CreateInstance(typeof(ReadOnlyCollection<>).MakeGenericType(TypeE),target);
                        SetValue(pi,target);
                        return;
                        }
                    }
                switch (reader.Name) {
                    case "ScriptText":
                        Script = reader.ReadElementContentAsString();
                        break;
                    case "Dictionary":
                        {
                        using (var r = reader.ReadSubtree()) {
                            r.MoveToContent();
                            ForEachE(r,(__)=>{
                                CreateE(r,out var o);
                                objects.Add(o);
                                });
                            }
                        }
                        break;
                    case "Styles":
                        {
                        using (var r = reader.ReadSubtree()) {
                            r.MoveToContent();
                            ForEachE(r,(__)=>{
                                CreateE(r,out var o);
                                objects.Add(o);
                                });
                            }
                        }
                        break;
                    default:
                        {
                        CreateE(reader,out var o);
                        objects.Add(o);
                        }
                        break;
                    }
                });
            UpdateReferences(objects);
            }
        #endregion
        #region M:Accept(IFastReportVisitor)
        public override void Accept(IFastReportVisitor visitor)
            {
            if (visitor == null) { throw new ArgumentNullException(nameof(visitor)); }
            visitor.Visit(this);
            }
        #endregion
        #region M:UpdateReferences(IList<FastReportObject>)
        [SuppressMessage("ReSharper", "LocalVariableHidesMember")]
        protected override void UpdateReferences(IList<FastReportObject> source) {
            using (var Parameters = PrepareChanges(this.Parameters))
            using (var Styles = PrepareChanges(this.Styles))
            using (var DataSources = PrepareChanges(this.DataSources))
            using (var Relations = PrepareChanges(this.Relations))
            using (var Totals = PrepareChanges(this.Totals))
            using (var Pages = PrepareChanges(this.Pages)) {
                foreach (var o in source) {
                         if (o is PageBase PageBase)                       { Pages.Add(PageBase);                 }
                    else if (o is DataConnectionBase DataConnectionBase)   { DataSources.Add(DataConnectionBase); }
                    else if (o is FastReportParameter FastReportParameter) { Parameters.Add(FastReportParameter); }
                    else if (o is Relation Relation)                       { Relations.Add(Relation);             }
                    else if (o is Total Total)                             { Totals.Add(Total);                   }
                    else if (o is Style Style) { Styles.Add(Style); }
                    }
                }
            }
        #endregion
        #region M:Serialize(XmlWriter,String)
        public override void Serialize(XmlWriter writer,String prefix) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            var type = GetType();
            var className = ClassName;
            using (writer.ElementGroup(className)) {
                SerializeAttributes(writer,this,prefix);
                if (!String.IsNullOrWhiteSpace(Script)) {
                    using (writer.ElementGroup("ScriptText")) {
                        writer.WriteRaw(EncodeString(Script));
                        }
                    }
                if (Styles.Any()) {
                    using (writer.ElementGroup("Styles")) {
                        Serialize(writer,Styles,prefix);
                        }
                    }
                if (DataSources.Any() || Parameters.Any() || Relations.Any()|| Totals.Any()) {
                    using (writer.ElementGroup("Dictionary")) {
                        Serialize(writer,DataSources,prefix);
                        Serialize(writer,Relations,prefix);
                        Serialize(writer,Parameters,prefix);
                        Serialize(writer,Totals,prefix);
                        }
                    }
                Serialize(writer,Children,prefix);
                }
            }
        #endregion
        }
    }
