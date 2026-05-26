using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Xml;
using JetBrains.Annotations;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using FieldAttribute=SqlObjectFieldMappingAttribute;
    public class FastReport : Base
        {
        [UsedImplicitly][Field] public FastReportLanguage ScriptLanguage { get; }
        [UsedImplicitly][Field("ReportInfo.Name")] public String Name { get; }
        [UsedImplicitly][Field("ReportInfo.Created")] public DateTime?  CreatedDate { get; }
        [UsedImplicitly][Field("ReportInfo.Modified")] public DateTime? ModifiedDate { get; }
        [UsedImplicitly][Field("ReportInfo.Author")] public String CreatedBy { get; }
        [UsedImplicitly][Field("ReportInfo.CreatorVersion")][TypeConverter(typeof(SqlVersionConverter))] public Version CreatedVersion { get; }
        [UsedImplicitly][Field] public Boolean DoublePass { get; }
        [UsedImplicitly][Field] public Boolean Compressed { get; }
        [UsedImplicitly][Field] public Boolean ConvertNulls { get; } = true;
        [UsedImplicitly][Field] public Boolean StoreInResources { get; } = true;
        [UsedImplicitly][Field] public Boolean AutoFillDataSet { get; } = true;
        [UsedImplicitly][Field] public String StartReportEvent { get; }
        [UsedImplicitly][Field] public String FinishReportEvent { get; }
        [UsedImplicitly][Field] public TextQuality TextQuality { get; }
        public IList<String> ReferencedAssemblies { get;private set; } = EmptyArray<String>.List;
        public String Script { get;private set; }

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
            while (reader.Read()) {
                switch (reader.NodeType) {
                    case XmlNodeType.Element:
                        {
                        switch (reader.Name) {
                            case "ScriptText":
                                Script = reader.ReadElementContentAsString();
                                break;
                            case "Dictionary":
                                {
                                using (var r = reader.ReadSubtree()) {
                                    ReadDataSources(r);
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
        #region M:ReadDataSources(XmlReader)
        private void ReadDataSources(XmlReader reader) {
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
        }
    }
