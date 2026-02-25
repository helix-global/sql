using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Threading;
using System.Xml;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    public class DataSchemaModelElement : SqlModelObject
        {
        public const String URI_DAC   = "http://schemas.microsoft.com/sqlserver/dac/Serialization/2012/02";
        public const String URI_XMLNS = "http://www.w3.org/2000/xmlns/";
        public static DataSchemaModelElement Ignore = new DataSchemaModelIgnoreElement();
        [DebuggerBrowsable(DebuggerBrowsableState.Never)] public virtual Boolean IsIgnore { get { return false; }}
        public virtual String Name { get;protected set; }
        protected internal virtual IList<DataSchemaModelAnnotation> Annotations { get; } = new List<DataSchemaModelAnnotation>();
        protected internal virtual IList<DataSchemaModelElement> Elements { get; } = new List<DataSchemaModelElement>();
        protected internal virtual IDictionary<String,DataSchemaModelRelationship> Relationships { get; } = new SortedDictionary<String,DataSchemaModelRelationship>();
        protected virtual DataSchemaModel Scope { get; }
        [SqlModelFieldMapping] public Int32? Disambiguator { get; }
        protected IList<String> MappedElementType { get; }
        [DebuggerBrowsable(DebuggerBrowsableState.Never)] protected ISet<String> SupportedRelationships { get; } = new HashSet<String>();

        protected DataSchemaModelElement(DataSchemaModel Scope)
            :base()
            {
            this.Scope = Scope;
            MappedElementType = new List<String>();
            var attributes = GetType().GetCustomAttributes<DataSchemaModelMappingAttribute>().ToArray();
            if (attributes.Length > 0) {
                foreach (var attribute in attributes) {
                    MappedElementType.Add(attribute.Type);
                    }
                }
            //MappedElementType = MappedElementType.AsReadOnly();
            SupportedRelationships.UnionWith(GetType().GetCustomAttributes<DataSchemaModelSupportedRelationshipAttribute>().Select(i=>i.Relationship));
            }

        private class DataSchemaModelIgnoreElement : DataSchemaModelElement
            {
            public override Boolean IsIgnore { get { return true; }}
            public DataSchemaModelIgnoreElement(DataSchemaModel Scope)
                : base(Scope)
                {
                }

            public DataSchemaModelIgnoreElement()
                : base(null)
                {
                }
            }

        #region M:ReadXmlA(XmlReader)
        protected override void ReadXmlA(XmlReader reader) {
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            while (reader.MoveToNextAttribute()) {
                switch (reader.LocalName) {
                    case "Type":
                        if (!MappedElementType.Contains(reader.Value)) { throw new InvalidDataException($@"Invalid Type=""{reader.Value}""."); }
                        break;
                    case "Name":
                        Name = reader.Value;
                        break;
                    case "xmlns" when reader.NamespaceURI == URI_XMLNS:
                        if (reader.Value != URI_DAC) { throw new InvalidDataException($@"Invalid xmlns=""{reader.Value}""."); }
                        break;
                    default:
                        ResolveFieldMappings(GetType(),out var mapping);
                        if (!mapping.TryGetValue(reader.LocalName, out var mi)) {
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
            while (reader.Read()) {
                switch (reader.NodeType) {
                    case XmlNodeType.Element:
                        {
                        switch (reader.Name) {
                            #region Property
                            case "Property":
                                {
                                ReadP(reader,out var o);
                                ResolvePropertyMappings(GetType(),out var mapping);
                                if (!mapping.TryGetValue(o.Name, out var descriptor)) {
                                    throw new NotSupportedException(
                                        (reader is IXmlLineInfo LineInfo)
                                        ? $@"[Line={LineInfo.LineNumber}] Property ""{o.Name}"" is not supported for ""{GetType().Name}""."
                                        : $@"Property ""{o.Name}"" is not supported for ""{GetType().Name}""."
                                        );
                                    }
                                try
                                    {
                                    if (descriptor.PropertyType == typeof(SqlScript)) {
                                        ApplyProperty(descriptor,new SqlScript(o.Value,o.QuotedIdentifiers,o.AnsiNulls));
                                        break;
                                        }
                                    ApplyProperty(descriptor,o.Value);
                                    }
                                catch(Exception e)
                                    {
                                    throw new Exception(e.Message,e);
                                    }
                                break;
                                }
                            #endregion
                            #region Relationship
                            case "Relationship":
                                {
                                ReadR(reader, out var o);
                                if (!SupportedRelationships.Contains(o.Name)) {
                                    throw new NotSupportedException(
                                        (reader is IXmlLineInfo LineInfo)
                                        ? $@"[Line={LineInfo.LineNumber}] Relationship ""{o.Name}"" is not supported for ""{GetType().Name}""."
                                        : $@"Relationship ""{o.Name}"" is not supported for ""{GetType().Name}""."
                                        );
                                    }
                                Relationships.Add(o.Name,o);
                                break;
                                }
                            #endregion
                            #region Element
                            case "Element":
                                {
                                var Type = reader.GetAttribute("Type");
                                var o = CreateElement(Scope,Type);
                                if (!o.IsIgnore) {
                                    using (var r = reader.ReadSubtree()) {
                                        o.ReadXml(r);
                                        }
                                    Elements.Add(o);
                                    }
                                }
                                break;
                            #endregion
                            #region Annotation
                            case "Annotation":
                                {
                                ReadA(reader, out var o);
                                Annotations.Add(o);
                                }
                                break;
                            #endregion
                            #region AttachedAnnotation
                            case "AttachedAnnotation":
                                reader.Skip();
                                break;
                            #endregion
                            default:
                                ReadXmlE(reader,reader.LocalName);
                                reader.Skip();
                                break;
                            }
                        }
                        break;
                    }
                }
            }
        #endregion
        #region M:ProcessP(DataSchemaModelProperty):Boolean
        protected virtual Boolean ProcessP(DataSchemaModelProperty o) { return false; }
        #endregion
        #region M:ReadXmlE(XmlReader,String)
        protected virtual void ReadXmlE(XmlReader reader,String localname) {
            throw new NotSupportedException($@"Element[""{reader.Name}""] not supported for ""{GetType().Name}"".");
            }
        #endregion
        #region M:ToString:String
        /// <summary>Returns a string that represents the current object.</summary>
        /// <returns>A string that represents the current object.</returns>
        public override String ToString()
            {
            return Name??base.ToString();
            }
        #endregion
        #region M:ReadA(XmlReader,{out}DataSchemaModelAnnotation)
        internal void ReadA(XmlReader reader,out DataSchemaModelAnnotation o) {
            o = (DataSchemaModelAnnotation)CreateElement(Scope,reader.GetAttribute("Type"));
            using (var r = reader.ReadSubtree()) {
                o.ReadXml(r);
                }
            reader.Skip();
            }
        #endregion
        #region M:ReadP(XmlReader,{out}DataSchemaModelElementProperty)
        protected void ReadP(XmlReader reader,out DataSchemaModelProperty o) {
            o = new DataSchemaModelProperty(Scope);
            using (var r = reader.ReadSubtree()) {
                o.ReadXml(r);
                }
            reader.Skip();
            }
        #endregion
        #region M:ReadR(XmlReader,{out}DataSchemaModelRelationship)
        internal void ReadR(XmlReader reader,out DataSchemaModelRelationship o) {
            o = new DataSchemaModelRelationship(Scope);
            using (var r = reader.ReadSubtree()) {
                o.ReadXml(r);
                }
            reader.Skip();
            }
        #endregion
        #region M:ResolvePropertyMappings(Type,{out}IDictionary<String,PropertyDescriptor>)
        private static void ResolvePropertyMappings(Type type, out IDictionary<String,PropertyDescriptor> mapping) {
            if (type == null) { throw new ArgumentNullException(nameof(type)); }
            mapping = default;
            using (UpgradeableReadLock(rwl)) {
                if (!PropertyMapping.TryGetValue(type, out mapping)) {
                    using (WriteLock(rwl)) {
                        PropertyMapping.Add(type,mapping = new Dictionary<String,PropertyDescriptor>());
                        foreach (var i in ResolveAttributeMappings<DataSchemaModelPropertyMappingAttribute>(type)) {
                            mapping[i.Key] = i.Value;
                            }
                        }
                    }
                }
            }
        #endregion
        #region M:UpdateRelationships
        protected virtual void UpdateRelationships() {
            foreach (var e in Elements) {
                e.UpdateRelationships();
                }
            foreach (var e in Relationships) {
                e.Value.UpdateRelationships();
                }
            }
        #endregion
        #region M:ApplyProperty(PropertyDescriptor,Object)
        protected virtual void ApplyProperty(PropertyDescriptor descriptor,Object value)
            {
            SetValue(descriptor,value);
            }
        #endregion

        public static DataSchemaModelElement CreateElement(DataSchemaModel Scope,String Type) {
            if (RegisteredTypes.TryGetValue(Type,out var type)) {
                var o = (DataSchemaModelElement)Activator.CreateInstance(type,BindingFlags.Public|BindingFlags.NonPublic|BindingFlags.Instance,null,new Object[]{ Scope },CultureInfo.DefaultThreadCurrentCulture);
                return o;
                }
            throw new NotSupportedException($@"Type ""{Type}"" mapping not found.");
            }

        private static readonly IDictionary<Type,IDictionary<String,PropertyDescriptor>> PropertyMapping = new Dictionary<Type,IDictionary<String,PropertyDescriptor>>();
        private static readonly ReaderWriterLockSlim rwl = new ReaderWriterLockSlim();

        protected static readonly IDictionary<String,Type> RegisteredTypes = new ConcurrentDictionary<String,Type>();
        static DataSchemaModelElement() {
            foreach (var type in typeof(DataSchemaModelElement).Assembly.GetTypes().Union(new []{typeof(DataSchemaModelIgnoreElement)})) {
                var attributes = type.GetCustomAttributes<DataSchemaModelMappingAttribute>().ToArray();
                if (attributes.Length > 0) {
                    foreach (var attribute in attributes)
                        {
                        RegisteredTypes.Add(attribute.Type,type);
                        }
                    }
                }
            }
        }
    }
