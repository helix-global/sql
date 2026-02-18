using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Threading;
using System.Xml;
using System.Xml.Schema;
using System.Xml.Serialization;

namespace BinaryStudio.SqlServer.Infrastructure.DAC
    {
    using UFieldInfo=FieldInfo;
    using UPropertyInfo=PropertyInfo;
    using UMemberInfo=MemberInfo;

    public class DataSchemaModelElement : IXmlSerializable
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
        protected IList<String> MappedElementType { get; }

        protected DataSchemaModelElement(DataSchemaModel Scope) {
            this.Scope = Scope;
            MappedElementType = new List<String>();
            var attributes = GetType().GetCustomAttributes<DataSchemaModelMappingAttribute>().ToArray();
            if (attributes.Length > 0) {
                foreach (var attribute in attributes) {
                    MappedElementType.Add(attribute.Type);
                    }
                }
            //MappedElementType = MappedElementType.AsReadOnly();
            }

        [DataSchemaModelMapping("SqlRoleMembership")]
        [DataSchemaModelMapping("SqlApplicationRole")]
        [DataSchemaModelMapping("SqlRole")]
        [DataSchemaModelMapping("SqlAssembly")]
        [DataSchemaModelMapping("SqlProcedure")]
        [DataSchemaModelMapping("SqlScalarFunction")]
        [DataSchemaModelMapping("SqlAggregate")]
        [DataSchemaModelMapping("SqlFullTextIndex")]
        [DataSchemaModelMapping("SqlStatistic")]
        [DataSchemaModelMapping("SqlDmlTrigger")]
        [DataSchemaModelMapping("SqlLogin")]
        [DataSchemaModelMapping("SqlUser")]
        [DataSchemaModelMapping("SqlFullTextCatalog")]
        [DataSchemaModelMapping("SqlPermissionStatement")]
        [DataSchemaModelMapping("SqlExtendedProperty")]
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

        #region M:IXmlSerializable.GetSchema:XmlSchema
        /// <summary>This method is reserved and should not be used. When implementing the <see langword="IXmlSerializable"/> interface, you should return <see langword="null"/> (<see langword="Nothing"/> in Visual Basic) from this method, and instead, if specifying a custom schema is required, apply the <see cref="T:System.Xml.Serialization.XmlSchemaProviderAttribute"/> to the class.</summary>
        /// <returns>An <see cref="T:System.Xml.Schema.XmlSchema"/> that describes the XML representation of the object that is produced by the <see cref="M:System.Xml.Serialization.IXmlSerializable.WriteXml(System.Xml.XmlWriter)"/> method and consumed by the <see cref="M:System.Xml.Serialization.IXmlSerializable.ReadXml(System.Xml.XmlReader)"/> method.</returns>
        XmlSchema IXmlSerializable.GetSchema()
            {
            throw new NotImplementedException();
            }
        #endregion
        #region M:IXmlSerializable.ReadXml(XmlReader)
        /// <summary>Generates an object from its XML representation.</summary>
        /// <param name="reader">The <see cref="T:System.Xml.XmlReader"/> stream from which the object is deserialized.</param>
        void IXmlSerializable.ReadXml(XmlReader reader) {
            ReadXml(reader);
            }

        /// <summary>Generates an object from its XML representation.</summary>
        /// <param name="reader">The <see cref="T:System.Xml.XmlReader"/> stream from which the object is deserialized.</param>
        protected internal virtual void ReadXml(XmlReader reader) {
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            reader.MoveToContent(); ReadXmlA(reader);
            reader.MoveToElement(); ReadXmlE(reader);
            }

        #region M:ReadXmlA(XmlReader)
        private void ReadXmlA(XmlReader reader) {
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
                        ResolveAttributeMappings(GetType(),out var mapping);
                        if (!mapping.TryGetValue(reader.LocalName, out var mi)) {
                            throw new NotSupportedException($@"@Attribute=""{reader.LocalName}"" is not supported for ""{GetType().FullName}"".");
                            }
                        mi.SetValue(this,reader.Value);
                        break;
                    }
                }
            }
        #endregion
        #region M:ReadXmlE(XmlReader)
        protected internal virtual void ReadXmlE(XmlReader reader) {
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
                                if (!mapping.TryGetValue(o.Name, out var mi)) {
                                    throw new NotSupportedException($@"Property ""{o.Name}"" is not supported for ""{GetType().Name}"".");
                                    }
                                try
                                    {
                                    mi.SetValue(this,o.Value);
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
        #endregion
        #region M:IXmlSerializable.WriteXml(XmlWriter)
        /// <summary>Converts an object into its XML representation.</summary>
        /// <param name="writer">The <see cref="T:System.Xml.XmlWriter"/> stream to which the object is serialized.</param>
        void IXmlSerializable.WriteXml(XmlWriter writer)
            {
            throw new NotImplementedException();
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
        #region M:ResolveAttributeMappings(Type,{out}IDictionary<String,MInfo>)
        private static void ResolveAttributeMappings(Type type, out IDictionary<String,MemberInfo> mapping) {
            if (type == null) { throw new ArgumentNullException(nameof(type)); }
            mapping = default;
            using (UpgradeableReadLock(rwl)) {
                if (!AttributeMapping.TryGetValue(type, out mapping)) {
                    using (WriteLock(rwl)) {
                        AttributeMapping.Add(type,mapping = new Dictionary<String,MemberInfo>());
                        foreach (var o in type.GetFields(BindingFlags.FlattenHierarchy|BindingFlags.Instance|BindingFlags.NonPublic|BindingFlags.Public)) {
                            var fi = o.GetCustomAttribute<DataSchemaModelAttributeMappingAttribute>();
                            if (fi != null) {
                                mapping.Add(fi.SourceName??o.Name,MemberInfo.Create(o,fi));
                                }
                            }
                        foreach (var o in type.GetProperties(BindingFlags.FlattenHierarchy|BindingFlags.Instance|BindingFlags.NonPublic|BindingFlags.Public)) {
                            var fi = o.GetCustomAttribute<DataSchemaModelAttributeMappingAttribute>();
                            if (fi != null) {
                                mapping[fi.SourceName??o.Name] = MemberInfo.Create(o,fi);
                                }
                            }
                        }
                    }
                }
            }
        #endregion
        #region M:ResolvePropertyMappings(Type,{out}IDictionary<String,MInfo>)
        private static void ResolvePropertyMappings(Type type, out IDictionary<String,MemberInfo> mapping) {
            if (type == null) { throw new ArgumentNullException(nameof(type)); }
            mapping = default;
            using (UpgradeableReadLock(rwl)) {
                if (!PropertyMapping.TryGetValue(type, out mapping)) {
                    using (WriteLock(rwl)) {
                        PropertyMapping.Add(type,mapping = new Dictionary<String,MemberInfo>());
                        foreach (var o in type.GetFields(BindingFlags.FlattenHierarchy|BindingFlags.Instance|BindingFlags.NonPublic|BindingFlags.Public)) {
                            var fi = o.GetCustomAttribute<DataSchemaModelPropertyMappingAttribute>();
                            if (fi != null) {
                                mapping.Add(fi.SourceName??o.Name,MemberInfo.Create(o,fi));
                                }
                            }
                        foreach (var o in type.GetProperties(BindingFlags.FlattenHierarchy|BindingFlags.Instance|BindingFlags.NonPublic|BindingFlags.Public)) {
                            var fi = o.GetCustomAttribute<DataSchemaModelPropertyMappingAttribute>();
                            if (fi != null) {
                                mapping[fi.SourceName??o.Name] = MemberInfo.Create(o,fi);
                                }
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

        public static DataSchemaModelElement CreateElement(DataSchemaModel Scope,String Type) {
            if (RegisteredTypes.TryGetValue(Type,out var type)) {
                var o = (DataSchemaModelElement)Activator.CreateInstance(type,BindingFlags.Public|BindingFlags.NonPublic|BindingFlags.Instance,null,new Object[]{ Scope },CultureInfo.DefaultThreadCurrentCulture);
                return o;
                }
            throw new NotSupportedException($@"Type ""{Type}"" mapping not found.");
            }

        private static readonly ReaderWriterLockSlim rwl = new ReaderWriterLockSlim();
        private static readonly IDictionary<Type,IDictionary<String,MemberInfo>> PropertyMapping = new Dictionary<Type,IDictionary<String,MemberInfo>>();
        private static readonly IDictionary<Type,IDictionary<String,MemberInfo>> AttributeMapping = new Dictionary<Type,IDictionary<String,MemberInfo>>();

        protected internal static IDisposable ReadLock(ReaderWriterLockSlim o)            { return new ReadLockScope(o);            }
        protected internal static IDisposable WriteLock(ReaderWriterLockSlim o)           { return new WriteLockScope(o);           }
        protected internal static IDisposable UpgradeableReadLock(ReaderWriterLockSlim o) { return new UpgradeableReadLockScope(o); }

        private class ReadLockScope : IDisposable
            {
            private ReaderWriterLockSlim o;
            public ReadLockScope(ReaderWriterLockSlim o)
                {
                this.o = o;
                o.EnterReadLock();
                }

            public void Dispose()
                {
                o.ExitReadLock();
                o = null;
                }
            }

        private class UpgradeableReadLockScope : IDisposable
            {
            private ReaderWriterLockSlim o;
            public UpgradeableReadLockScope(ReaderWriterLockSlim o)
                {
                this.o = o;
                o.EnterUpgradeableReadLock();
                }

            public void Dispose()
                {
                o.ExitUpgradeableReadLock();
                o = null;
                }
            }

        private class WriteLockScope : IDisposable
            {
            private ReaderWriterLockSlim o;
            public WriteLockScope(ReaderWriterLockSlim o)
                {
                this.o = o;
                o.EnterWriteLock();
                }

            public void Dispose()
                {
                o.ExitWriteLock();
                o = null;
                }
            }

        private abstract class MemberInfo
            {
            public abstract Boolean CanWrite { get; }
            public abstract Boolean CanRead { get; }
            public abstract TypeConverter Converter { get; }
            public abstract Type MemberType { get; }
            protected UMemberInfo Source { get;set; }
            protected String InfoType { get;set; }

            #region M:Create(PropertyInfo,IDataSchemaModelMappingAttribute):MemberInfo
            public static MemberInfo Create(UPropertyInfo source,IDataSchemaModelMappingAttribute mappingAttribute)
                {
                return new PropertyInfo(source,mappingAttribute);
                }
            #endregion
            #region M:Create(FieldInfo,IDataSchemaModelMappingAttribute):MInfo
            public static MemberInfo Create(UFieldInfo source,IDataSchemaModelMappingAttribute mappingAttribute)
                {
                return new FieldInfo(source,mappingAttribute);
                }
            #endregion

            protected MemberInfo(UMemberInfo source,IDataSchemaModelMappingAttribute mappingAttribute) {
                if (source == null) { throw new ArgumentNullException(nameof(source)); }
                if (mappingAttribute == null) { throw new ArgumentNullException(nameof(mappingAttribute)); }
                Source = source;
                }

            #region M:SetValue(Object,Object)
            public void SetValue(Object o, Object value) {
                if (value is DBNull) { value = null; }

                Object r;
                var converter = Converter;
                try
                    {
                    if (MemberType == typeof(Object)) { r = value; }
                    else 
                        {
                        r = (converter != null)
                            ? converter.ConvertFrom(value)
                            : value;
                        }
                    }
                catch (Exception e)
                    {
                    //e.Add("SourceValue",value);
                    //if (value != null)
                    //    {
                    //    e.Add("SourceValueType",value.GetType().Name);
                    //    }
                    //e.Add("TargetType",MemberType.FullName);
                    //e.Add("Converter",converter?.GetType()?.FullName);
                    throw;
                    }

                try
                    {
                         if (Source is UPropertyInfo pi) { pi.SetValue(o,r,null); }
                    else if (Source is UFieldInfo    fi) { fi.SetValue(o,r);      }
                    }
                catch (Exception e)
                    {
                    //e.Add($"{InfoType}Name",Source.Name);
                    //e.Add($"{InfoType}Type",MemberType.Name);
                    //e.Add("SourceValue",r);
                    //if (r != null)
                    //    {
                    //    e.Add("SourceValueType",r.GetType().Name);
                    //    }
                    //e.Add("TargetType",MemberType.FullName);
                    //e.Add("Converter",converter?.GetType()?.FullName);
                    throw;
                    }
                }
            #endregion
            #region M:GetConverter(Type):TypeConverter
            protected static TypeConverter GetConverter(Type source) {
                var o = TypeDescriptor.GetConverter(source);
                     if (source == typeof(Boolean )) { o = new BooleanConverter(); }
                else if (source == typeof(Boolean?)) { o = new BooleanConverter(); }
                else if (source == typeof(Int32))    { o = new Int32Converter(); }
                else if (source == typeof(Int32?))   { o = new Int32Converter(); }
                return o;
                }
            #endregion
            }

        private sealed class PropertyInfo : MemberInfo
            {
            public override Boolean CanWrite { get; }
            public override Boolean CanRead  { get; }
            public override Type MemberType  { get; }
            public override TypeConverter Converter { get; }

            #region ctor{PropertyInfo,IDataSchemaModelMappingAttribute}
            public PropertyInfo(UPropertyInfo source,IDataSchemaModelMappingAttribute mappingAttribute)
                :base(source,mappingAttribute)
                {
                CanWrite = source.CanWrite;
                CanRead  = source.CanRead;
                MemberType = source.PropertyType;
                Converter = GetConverter(MemberType);
                InfoType = "Property";

                if (!CanWrite) {
                    #if NET40
                    var mi = source.GetGetMethod();
                    #else
                    var mi = source.GetMethod;
                    #endif
                    if (mi.GetCustomAttribute<CompilerGeneratedAttribute>() != null) {
                        UFieldInfo fi = null;
                        var type = source.DeclaringType;
                        do
                            {
                            fi = type.GetField($"<{source.Name}>k__BackingField",BindingFlags.Instance|BindingFlags.NonPublic);
                            if (fi != null) { break; }
                            type = type.BaseType;
                            } while (type != null);
                        if (fi != null)
                            {
                            Source = fi;
                            CanWrite = true;
                            CanRead  = true;
                            InfoType = "Field";
                            }
                        }
                    }
                }
            #endregion
            }

        private sealed class FieldInfo : MemberInfo
            {
            public override Boolean CanWrite { get; }
            public override Boolean CanRead  { get; }
            public override Type MemberType  { get; }
            public override TypeConverter Converter { get; }

            public FieldInfo(UFieldInfo source,IDataSchemaModelMappingAttribute mappingAttribute)
                :base(source,mappingAttribute)
                {
                CanWrite = true;
                CanRead  = true;
                MemberType = source.FieldType;
                Converter = GetConverter(MemberType);
                InfoType = "Field";
                }
            }

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
