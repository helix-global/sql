using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Collections.ObjectModel;
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
    [TypeConverter(typeof(DataSchemaModelConverter))]
    public class DataSchemaModelElement : SqlModelObject
        {
        public const String URI_DAC   = "http://schemas.microsoft.com/sqlserver/dac/Serialization/2012/02";
        public const String URI_XMLNS = "http://www.w3.org/2000/xmlns/";
        [DebuggerBrowsable(DebuggerBrowsableState.Never)] public virtual Boolean IsIgnore { get { return false; }}
        public virtual String Name { get;protected set; }
        protected internal virtual IList<DataSchemaModelAnnotation> Annotations { get; } = new List<DataSchemaModelAnnotation>();
        protected internal virtual IList<DataSchemaModelElement> Elements { get; } = new List<DataSchemaModelElement>();
        protected internal virtual IList<SqlObjectReference> References { get; } = new List<SqlObjectReference>();
        protected internal virtual IDictionary<String,DataSchemaModelRelationship> Relationships { get; } = new SortedDictionary<String,DataSchemaModelRelationship>();
        protected virtual DataSchemaModel Scope { get; }
        [SqlModelFieldMapping] public Int32? Disambiguator { get; }
        protected IList<String> MappedElementType { get; }
        //[DebuggerBrowsable(DebuggerBrowsableState.Never)] protected ISet<String> SupportedRelationships { get; } = new HashSet<String>();
        protected internal Int32? LineNumber { get;internal set; }

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
            //SupportedRelationships.UnionWith(GetType().GetCustomAttributes<DataSchemaModelSupportedRelationshipAttribute>().Select(i=>i.Relationship));
            InitializeRelationships();
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
                                ResolveRelationshipMappings(GetType(),out var mapping);
                                if (mapping.Values.FirstOrDefault(i=>String.Equals(i.Name,o.Name)) == null) {
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
                                    o.LineNumber = (reader as IXmlLineInfo)?.LineNumber;
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
                            #region References
                            case "References":
                                {
                                var r = reader.GetAttribute("Name");
                                var ExternalSource = reader.GetAttribute("ExternalSource");
                                References.Add(new DataSchemaModelObjectReference(SqlObjectIdentifier.Parse(r),String.Equals(ExternalSource,"BuiltIns")){
                                    Disambiguator = PropSI4(reader.GetAttribute("Disambiguator"))
                                    });
                                return;
                                }
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
            using (UpgradeableReadLock(prwl)) {
                if (!PropertyMapping.TryGetValue(type, out mapping)) {
                    using (WriteLock(prwl)) {
                        PropertyMapping.Add(type,mapping = new Dictionary<String,PropertyDescriptor>());
                        foreach (var i in ResolveAttributeMappings<DataSchemaModelPropertyMappingAttribute>(type)) {
                            mapping[i.Key] = i.Value;
                            }
                        }
                    }
                }
            }
        #endregion
        #region M:ResolveRelationshipMappings(Type,{out}IDictionary<String,Relationship>)
        private static void ResolveRelationshipMappings(Type type, out IDictionary<String,RelationshipDescriptor> mapping) {
            if (type == null) { throw new ArgumentNullException(nameof(type)); }
            mapping = default;
            using (UpgradeableReadLock(rrwl)) {
                if (!RelationshipMapping.TryGetValue(type, out mapping)) {
                    using (WriteLock(rrwl)) {
                        RelationshipMapping.Add(type,mapping = new Dictionary<String,RelationshipDescriptor>());
                        foreach (var pair in ResolveAttributeMappings<RelationshipAttribute>(type)) {
                            var attribute = (RelationshipAttribute)pair.Value.Attributes[typeof(RelationshipAttribute)];
                            var multiplicity = attribute.Multiplicity;
                            if (multiplicity.IsMultiple) {
                                var typeP = pair.Value.PropertyType;
                                if (!typeP.IsConstructedGenericType) { throw new InvalidOperationException($@"Relationship ""{pair.Key}"" property ""{pair.Value.Name}"" should be declared as ""IList<T>"" type."); }
                                var typeG = typeP.GetGenericTypeDefinition();
                                if (typeG != typeof(IList<>)) { throw new InvalidOperationException($@"Relationship ""{pair.Key}"" property ""{pair.Value.Name}"" should be declared as ""IList<T>"" type."); }
                                var typeE = typeP.GenericTypeArguments[0];
                                #region references
                                if (typeE == typeof(SqlObjectReference))
                                    {
                                    mapping[pair.Key] = new RelationshipDescriptor{
                                        Kind = RelationshipKind.Reference,
                                        RelationshipType = typeE,
                                        PropertyDescriptor = pair.Value,
                                        Multiplicity = multiplicity,
                                        Name = pair.Key
                                        };
                                    continue;
                                    }
                                #endregion
                                #region elements
                                else
                                    {
                                    mapping[pair.Key] = new RelationshipDescriptor{
                                        Kind = (attribute.Kind == RelationshipKind.Auto)
                                            ? RelationshipKind.Element
                                            : attribute.Kind,
                                        RelationshipType = typeE,
                                        PropertyDescriptor = pair.Value,
                                        Multiplicity = multiplicity,
                                        Name = pair.Key
                                        };
                                    continue;
                                    }
                                #endregion
                                }
                            else
                                {
                                var typeE = pair.Value.PropertyType;
                                #region references
                                if (typeE == typeof(SqlObjectReference))
                                    {
                                    mapping[pair.Key] = new RelationshipDescriptor{
                                        Kind = RelationshipKind.Reference,
                                        RelationshipType = typeE,
                                        PropertyDescriptor = pair.Value,
                                        Multiplicity = multiplicity,
                                        Name = pair.Key
                                        };
                                    continue;
                                    }
                                #endregion
                                #region elements
                                mapping[pair.Key] = new RelationshipDescriptor{
                                    Kind = (attribute.Kind == RelationshipKind.Auto)
                                        ? RelationshipKind.Element
                                        : attribute.Kind,
                                    RelationshipType = typeE,
                                    PropertyDescriptor = pair.Value,
                                    Multiplicity = multiplicity,
                                    Name = pair.Key
                                    };
                                #endregion
                                //else
                                //    {

                                //    }
                                //throw new InvalidOperationException($@"The ""{pair.Value.Name}"" property of the ""{pair.Key}"" relationship must be declared as type ""SqlObjectReference"" or a type derived from ""DataSchemaModelElement"" or a type marked as [Relationship].");
                                }
                            }
                        }
                    }
                }
            }
        #endregion
        #region M:UpdateRelationships
        protected virtual void UpdateRelationships() {
            foreach (var e in Elements)      { e.UpdateRelationships();       }
            foreach (var e in Relationships) { e.Value.UpdateRelationships(); }
            ResolveRelationshipMappings(GetType(),out var mapping);
            foreach (var descriptor in mapping.Values) {
                var r = (IList)Activator.CreateInstance(typeof(List<>).MakeGenericType(descriptor.RelationshipType));
                if (Relationships.TryGetValue(descriptor.Name,out var relationship)) {
                    switch (descriptor.Kind) {
                        case RelationshipKind.Reference:
                            r = AsReadOnly(descriptor.RelationshipType,
                                AddRange(r,relationship.References));
                            break;
                        case RelationshipKind.Element:
                            r = AsReadOnly(descriptor.RelationshipType,
                                AddRange(r,relationship.Elements));
                            break;
                        case RelationshipKind.Reference|RelationshipKind.Annotation:
                            AddRange(r,relationship.References);
                            AddRange(r,relationship.Annotations);
                            r = AsReadOnly(descriptor.RelationshipType,r);
                            break;
                        default:
                            throw new NotSupportedException();
                        }
                    }
                ValidateMultiplicity(descriptor,r);
                #region multiple
                if (descriptor.Multiplicity.IsMultiple) {
                    descriptor.PropertyDescriptor.SetValue(this,r);
                    }
                #endregion
                #region single
                else
                    {
                    descriptor.PropertyDescriptor.SetValue(this,FirstOrDefault(r));
                    }
                #endregion
                }
            }

        #region M:AddRange(IList,IEnumerable):IList
        private static IList AddRange(IList target,IEnumerable source) {
            foreach (var e in source) {
                target.Add(e);
                }
            return target;
            }
        #endregion
        #region M:AsReadOnly(Type,IList):IList
        private IList AsReadOnly(Type type,IList source) {
            return (IList)Activator.CreateInstance(typeof(ReadOnlyCollection<>).MakeGenericType(type),source);
            }
        #endregion
        #region M:FirstOrDefault(IList):Object
        private static Object FirstOrDefault(IList elements) {
            return (elements.Count > 0)
                ? elements[0]
                : null;
            }
        #endregion
        //#region M:OfType(Type,IEnumerable):IEnumerable
        //private static IEnumerable OfType(Type type,IEnumerable elements) {
        //    foreach (var e in elements) {
        //        if (e != null) {
        //            if (type.IsAssignableFrom(e.GetType())) {
        //                yield return e;
        //                }
        //            }
        //        }
        //    }
        //#endregion
        #region M:ValidateMultiplicity(Relationship,IList)
        private void ValidateMultiplicity(RelationshipDescriptor relationship,IList items) {
            var count = (UInt64)items.Count;
            var multiplicity = relationship.Multiplicity;
            var lineinfo = (LineNumber != null) ? $@" [Line={LineNumber}]." : String.Empty;
            if (multiplicity.Lower > count) {
                throw new InvalidOperationException(
                    String.Equals(relationship.Name,relationship.PropertyDescriptor.Name)
                        ? $@"The ""{relationship.Name}"" relationship requires a minimum {multiplicity.Lower} values.{lineinfo}"
                        : $@"The ""{relationship.Name}""{{{relationship.PropertyDescriptor.Name}}} relationship requires a minimum {multiplicity.Lower} values.{lineinfo}");
                }
            if (!multiplicity.Upper.IsUnlimited) {
                if (count > (UInt64)multiplicity.Upper) {
                    throw new InvalidOperationException(
                        $@"The {relationship} relationship requires a maximum {multiplicity.Upper} values.{lineinfo}");
                    }
                }
            }
        #endregion
        #endregion
        #region M:InitializeRelationships
        private void InitializeRelationships() {
            ResolveRelationshipMappings(GetType(),out var mapping);
            foreach (var descriptors in mapping.Values) {
                if (descriptors.Multiplicity.IsMultiple) {
                    descriptors.PropertyDescriptor.
                        SetValue(this,AsReadOnly(descriptors.RelationshipType,
                        Array.CreateInstance(descriptors.RelationshipType,0)));
                    }
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

        private class RelationshipDescriptor
            {
            public String Name { get;set; }
            public Type RelationshipType { get;set; }
            public RelationshipKind Kind { get;set; }
            public PropertyDescriptor PropertyDescriptor { get;set; }
            public Multiplicity Multiplicity { get;set; }

            public override String ToString() {
                return String.Equals(Name,PropertyDescriptor.Name)
                    ? $@"""{Name}"""
                    : $@"""{Name}""{{{PropertyDescriptor.Name}}}";
                }
            }

        private static readonly IDictionary<Type,IDictionary<String,PropertyDescriptor>> PropertyMapping     = new Dictionary<Type,IDictionary<String,PropertyDescriptor>>();
        private static readonly IDictionary<Type,IDictionary<String,RelationshipDescriptor>> RelationshipMapping = new Dictionary<Type,IDictionary<String,RelationshipDescriptor>>();
        private static readonly ReaderWriterLockSlim prwl  = new ReaderWriterLockSlim();
        private static readonly ReaderWriterLockSlim rrwl = new ReaderWriterLockSlim();

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
        public static DataSchemaModelElement Ignore = new DataSchemaModelIgnoreElement();
        private static readonly MethodInfo ListAddRange = typeof(List<>).GetMethod("AddRange");
        }
    }
