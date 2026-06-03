using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;
using System;
using System.Collections;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Diagnostics.CodeAnalysis;
using System.IO;
using System.Xml;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    internal sealed class FastReport : Base
        {
        [UsedImplicitly][Field(Order=4000000)] public FastReportLanguage ScriptLanguage { get; }
        [UsedImplicitly][Field("ReportInfo.Name",Order=5000100)] public override String Name { get; }
        [UsedImplicitly][Field("ReportInfo.Created",Order=5000300)] public DateTime?  CreatedDate { get; }
        [UsedImplicitly][Field("ReportInfo.Modified",Order=5000400)] public DateTime? ModifiedDate { get; }
        [UsedImplicitly][Field("ReportInfo.Author",Order=5000200)] public String CreatedBy { get; }
        [UsedImplicitly][Field("ReportInfo.CreatorVersion",Order=5000500)][TypeConverter(typeof(SqlVersionConverter))] public Version CreatedVersion { get; }
        [UsedImplicitly][Field(Order=4000200)][DefaultValue(false)] public Boolean DoublePass { get; }
        [UsedImplicitly][Field(Order=4000300)][DefaultValue(false)] public Boolean Compressed { get; }
        [UsedImplicitly][Field(Order=4000100)][DefaultValue(true)]  public Boolean ConvertNulls { get; } = true;
        [UsedImplicitly][Field][DefaultValue(true)]  public Boolean StoreInResources { get; } = true;
        [UsedImplicitly][Field][DefaultValue(true)]  public Boolean AutoFillDataSet { get; } = true;
        [UsedImplicitly][Field(Order=4000600)][DefaultValue(false)] public Boolean SmoothGraphics { get; }
        [UsedImplicitly][Field(Order=4000400)][DefaultValue(false)] public Boolean UseFileCache { get; }
        [UsedImplicitly][Field(Order=4001000)] public String StartReportEvent { get; }
        [UsedImplicitly][Field(Order=4001100)] public String FinishReportEvent { get; }
        [UsedImplicitly][Field(Order=4000700)] public String Password { get; }
        [UsedImplicitly][Field(Order=4000500)][DefaultValue(TextQuality.Default)] public TextQuality TextQuality { get; }
        public IList<String> ReferencedAssemblies { get;private set; } = EmptyArray<String>.List;
        public String Script { get;private set; }
        [UsedImplicitly][Field(Order=4000900)][DefaultValue(0)] public Int32 MaxPages { get; }
        [UsedImplicitly][Field(Order=4000800)][DefaultValue(1)] public Int32 InitialPageNumber { get; } = 1;
        public IList<DataConnectionBase> DataSources { get; } = new SqlObjectCollection<DataConnectionBase>();
        public IList<FastReportParameter> Parameters { get; } = new SqlObjectCollection<FastReportParameter>();
        public IList<PageBase> Pages { get; } = new SqlObjectCollection<PageBase>();

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
            using (var reader = XmlReader.Create(source,new XmlReaderSettings {
                IgnoreComments = true,
                }))
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
            ReferencedAssemblies = new List<String>();
            try
                {
                while (reader.MoveToNextAttribute()) {
                    switch (reader.LocalName) {
                        case "ReferencedAssemblies":
                            ReferencedAssemblies.AddRange(reader.Value.
                                Split(new []{'\r','\n'},StringSplitOptions.RemoveEmptyEntries));
                            break;
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
            finally
                {
                ReferencedAssemblies = ReferencedAssemblies.AsReadOnly();
                }
            }
        #endregion
        #region M:ReadXmlE(XmlReader)
        protected override void ReadXmlE(XmlReader reader) {
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
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
                            using (var Parameters = PrepareChanges(this.Parameters))
                            using (var DataSources = PrepareChanges(this.DataSources)) {
                                r.MoveToContent();
                                ForEachE(r,(__)=>{
                                    CreateE(r,out var o);
                                         if (o is FastReportParameter parameter) { Parameters.Add(parameter);   }
                                    else if (o is DataConnectionBase connection) { DataSources.Add(connection); }
                                    });
                                }
                            }
                        }
                        break;
                    case "Styles":
                        {
                        using (var r = reader.ReadSubtree()) {
                            ReadStyles(r);
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
        #region M:ReadStyles(XmlReader)
        private void ReadStyles(XmlReader reader) {
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            reader.MoveToContent();
            while (reader.Read()) {
                switch (reader.NodeType) {
                    case XmlNodeType.Element:
                        {
                        switch (reader.Name) {
                            default:
                                if (RegisteredTypes.TryGetValue(reader.Name, out var type)) {
                                    using (var r = reader.ReadSubtree()) {
                                        var o = (FastReportObject)Activator.CreateInstance(type,nonPublic: true);
                                        o.ReadXml(r);
                                        reader.Skip();
                                        }
                                    break;
                                    }
                                throw new NotSupportedException(
                                    (reader is IXmlLineInfo LineInfo)
                                    ? $@"[Line={LineInfo.LineNumber}] Element <{reader.Name}> is not supported for ""{GetType().FullName}""."
                                    : $@"<{reader.Name}> is not supported for ""{GetType().FullName}""."
                                    );
                            }
                        break;
                        }
                    }
                }
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
            using (var Pages = PrepareChanges(this.Pages)) {
                foreach (var o in source) {
                    if (o is PageBase PageBase) {
                        Pages.Add(PageBase);
                        }
                    }
                }
            }
        #endregion
        }
    }
