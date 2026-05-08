using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Text.RegularExpressions;
using System.Threading;
using System.Xml;
using System.Xml.Schema;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public abstract class SqlObject : ISqlXmlSerializable,IServiceProvider
        {
        public const String URI_XSINIL = "http://www.w3.org/2001/XMLSchema-instance";
        public IServiceProvider Context { get; }

        #region ctor
        protected SqlObject()
            {
            }
        #endregion
        #region ctor{IServiceProvider,Object}
        protected SqlObject(IServiceProvider context,Object source) {
            Context = context;
            if (source != null) {
                ResolveFieldMappings(GetType(),out var mapping);
                ApplyProperties(mapping,source);
                }
            }
        #endregion
        #region ctor{IDictionary<String,Object>}
        protected SqlObject(IDictionary<String,Object> source) {
            if (source != null) {
                ResolveFieldMappings(GetType(),out var mapping);
                ApplyProperties(mapping,source);
                }
            }
        #endregion
        #region ctor{DataRow}
        protected SqlObject(IServiceProvider context,DataRow source) {
            Context = context;
            if (source != null) {
                ResolveFieldMappings(GetType(),out var mapping);
                ApplyProperties(mapping,source);
                }
            }
        #endregion
        #region ctor{IDataRecord}
        protected SqlObject(IDataRecord source) {
            if (source != null) {
                ResolveFieldMappings(GetType(),out var mapping);
                ApplyProperties(mapping,source);
                }
            }
        #endregion

        #region M:ResolveAttributeMappings<T>(Type):IEnumerable<KeyValuePair<String,PropertyDescriptor>>
        protected static IEnumerable<KeyValuePair<String,PropertyDescriptor>> ResolveAttributeMappings<T>(Type Type)
            where T: Attribute,ISqlModelMappingAttribute
            {
            if (Type == null) { throw new ArgumentNullException(nameof(Type)); }
            foreach (var o in Type.GetFields(BindingFlags.FlattenHierarchy|BindingFlags.Instance|BindingFlags.NonPublic|BindingFlags.Public)) {
                var attribute = o.GetCustomAttribute<T>();
                if (attribute != null) {
                    yield return new KeyValuePair<String,PropertyDescriptor>(attribute.Source??o.Name,new PropertyDescriptorF(o));
                    }
                }
            foreach (var o in Type.GetProperties(BindingFlags.FlattenHierarchy|BindingFlags.Instance|BindingFlags.NonPublic|BindingFlags.Public)) {
                var attribute = o.GetCustomAttribute<T>();
                if (attribute != null) {
                    if (!o.CanWrite) {
                        var mi = o.GetMethod;
                        if (mi.GetCustomAttribute<CompilerGeneratedAttribute>() != null) {
                            // Auto-property with init-only setter, treat it as writable
                            var type = Type;
                            FieldInfo fi;
                            do
                                {
                                fi = type.GetField($"<{o.Name}>k__BackingField",BindingFlags.Instance|BindingFlags.NonPublic);
                                if (fi != null) { break; }
                                type = type.BaseType;
                                }
                            while (type != null);
                            if (fi != null)
                                {
                                yield return new KeyValuePair<String,PropertyDescriptor>(
                                    attribute.Source??o.Name,
                                    new PropertyDescriptorF(fi,o.Name,o.GetCustomAttributes()));
                                continue;
                                }
                            }
                        }
                    yield return new KeyValuePair<String,PropertyDescriptor>(
                        attribute.Source??o.Name,new PropertyDescriptorP(o));
                    }
                }
            }
        #endregion
        #region M:ResolveFieldMappings(Type,{out}IDictionary<String,PropertyDescriptor>)
        protected static void ResolveFieldMappings(Type Type,out IDictionary<String,PropertyDescriptor> mapping) {
            if (Type == null) { throw new ArgumentNullException(nameof(Type)); }
            mapping = default;
            using (UpgradeableReadLock(rwl)) {
                if (!PropertyMapping.TryGetValue(Type, out mapping)) {
                    using (WriteLock(rwl)) {
                        PropertyMapping.Add(Type,mapping = new Dictionary<String,PropertyDescriptor>());
                        foreach (var i in ResolveAttributeMappings<SqlModelFieldMappingAttribute>(Type)) {
                            mapping[i.Key] = i.Value;
                            }
                        }
                    }
                }
            }
        #endregion
        #region M:ApplyProperties(IDictionary<String,PropertyDescriptor>,IDictionary<String,Object>)
        private void ApplyProperties(IDictionary<String,PropertyDescriptor> mapping,IDictionary<String,Object> source) {
            if (mapping == null) { throw new ArgumentNullException(nameof(mapping)); }
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            foreach (var i in mapping) {
                if (source.TryGetValue(i.Key,out var o)) {
                    SetValue(i.Value,o);
                    }
                }
            }
        #endregion
        #region M:ApplyProperties(IDictionary<String,PropertyDescriptor>,IDataRecord)
        private void ApplyProperties(IDictionary<String,PropertyDescriptor> mapping,IDataRecord source) {
            if (mapping == null) { throw new ArgumentNullException(nameof(mapping)); }
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            var c = source.FieldCount;
            for (var i = 0; i < c; i++) {
                var name = source.GetName(i);
                if (mapping.TryGetValue(name, out var mi)) {
                    var o = source.GetValue(i);
                    SetValue(mi,o);
                    }
                }
            }
        #endregion
        #region M:ApplyProperties(IDictionary<String,PropertyDescriptor>,DataRow)
        private void ApplyProperties(IDictionary<String,PropertyDescriptor> mapping,DataRow source) {
            if (mapping == null) { throw new ArgumentNullException(nameof(mapping)); }
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            foreach (var i in mapping) {
                if (source.Table.Columns.Contains(i.Key)) {
                    SetValue(i.Value,source[i.Key]);
                    }
                }
            }
        #endregion
        #region M:ApplyProperties(IDictionary<String,PropertyDescriptor>,Object)
        private void ApplyProperties(IDictionary<String,PropertyDescriptor> mapping,Object source) {
            if (mapping == null) { throw new ArgumentNullException(nameof(mapping)); }
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            var descriptors = TypeDescriptor.GetProperties(source).OfType<PropertyDescriptor>().ToDictionary(i=>i.Name,i=>i);
            foreach (var descriptor in descriptors) {
                if (mapping.TryGetValue(descriptor.Key,out var o)) {
                    SetValue(o,descriptor.Value.GetValue(source));
                    }
                }
            foreach (var pi in source.GetType().GetProperties(BindingFlags.Instance|BindingFlags.NonPublic)) {
                if (mapping.TryGetValue(pi.Name,out var o)) {
                    SetValue(o,pi.GetValue(source));
                    }
                }
            }
        #endregion
        #region M:SetValue(PropertyDescriptor,Object)
        protected virtual void SetValue(PropertyDescriptor descriptor,Object value) {
            if (descriptor == null) { throw new ArgumentNullException(nameof(descriptor)); }
            if (value is DBNull) { value = null; }
            descriptor.SetValue(this,value);
            }
        #endregion
        #region M:ISqlXmlSerializable.GetSchema:XmlSchema
        /// <summary>This method is reserved and should not be used. When implementing the <see langword="IXmlSerializable"/> interface, you should return <see langword="null"/> (<see langword="Nothing"/> in Visual Basic) from this method, and instead, if specifying a custom schema is required, apply the <see cref="T:System.Xml.Serialization.XmlSchemaProviderAttribute"/> to the class.</summary>
        /// <returns>An <see cref="T:System.Xml.Schema.XmlSchema"/> that describes the XML representation of the object that is produced by the <see cref="M:System.Xml.Serialization.IXmlSerializable.WriteXml(System.Xml.XmlWriter)"/> method and consumed by the <see cref="M:System.Xml.Serialization.IXmlSerializable.ReadXml(System.Xml.XmlReader)"/> method.</returns>
        XmlSchema ISqlXmlSerializable.GetSchema()
            {
            throw new NotImplementedException();
            }
        #endregion
        #region M:ISqlXmlSerializable.ReadXml(XmlReader)
        /// <summary>Generates an object from its XML representation.</summary>
        /// <param name="reader">The <see cref="T:System.Xml.XmlReader"/> stream from which the object is deserialized.</param>
        void ISqlXmlSerializable.ReadXml(XmlReader reader) {
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
        protected virtual void ReadXmlA(XmlReader reader) {
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            throw new NotImplementedException();
            }
        #endregion
        #region M:ReadXmlE(XmlReader)
        protected virtual void ReadXmlE(XmlReader reader) {
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            throw new NotImplementedException();
            }
        #endregion
        #endregion
        #region M:ISqlXmlSerializable.WriteXml(ISqlXmlWriter)
        /// <summary>Converts an object into its XML representation.</summary>
        /// <param name="writer">The <see cref="T:BinaryStudio.SqlServer.Infrastructure.ISqlXmlWriter"/> stream to which the object is serialized.</param>
        public virtual void WriteXml(ISqlXmlWriter writer)
            {
            throw new NotImplementedException();
            }
        #endregion
        #region M:PropB(Object):Boolean?
        protected static Boolean? PropB(Object value) {
            return SqlBooleanConverter.ConvertFromObject(value);
            }
        #endregion
        #region M:PropB(Object,Boolean):Boolean
        protected static Boolean PropB(Object value, Boolean defaultValue)
            {
            return SqlBooleanConverter.ConvertFromObject(value,defaultValue);
            }
        #endregion
        #region M:PropSI8(Object):Int64?
        protected static Int64? PropSI8(Object value) {
            return SqlInt64Converter.ConvertFromObject(value);
            }
        #endregion
        #region M:PropSI8(Int32,Int32):Int64
        internal static Int64 PropSI8(Int32 hi, Int32 lo)
            {
            var r = unchecked((Int64)PropUI8(
                unchecked((UInt32)hi),
                unchecked((UInt32)lo)));
            return r;
            }
        #endregion
        #region M:PropUI8(UInt32,UInt32):UInt64
        protected internal static UInt64 PropUI8(UInt32 hi, UInt32 lo) {
            var r = (((UInt64)hi) << 32) | lo;
            return r;
            }
        #endregion
        #region M:PropSI4(Object):Int32?
        protected static Int32? PropSI4(Object value) {
            return SqlInt32Converter.ConvertFromObject(value);
            }
        #endregion
        #region M:PropSI4(Object,Int32):Int32
        protected static Int32 PropSI4(Object value,Int32 defaultvalue) {
            return SqlInt32Converter.ConvertFromObject(value,defaultvalue);
            }
        #endregion
        #region M:PropSI4(Int16,Int16):Int32
        internal static Int32 PropSI4(Int16 hi,Int16 lo)
            {
            var r = unchecked((Int32)PropUI4(
                unchecked((UInt16)hi),
                unchecked((UInt16)lo)));
            return r;
            }
        #endregion
        #region M:PropUI4(UInt16,UInt16):UInt32
        protected internal static UInt32 PropUI4(UInt16 hi,UInt16 lo) {
            var r = (((UInt32)hi) << 16) | lo;
            return r;
            }
        #endregion
        #region M:PropE<E>(Object):E?
        protected static E? PropE<E>(Object value)
            where E: struct,Enum
            {
            return SqlEnumConverter<E>.ConvertFromObject(value);
            }
        #endregion
        #region M:PropE<E>(Object,E):E
        protected static E PropE<E>(Object value,E defaultvalue)
            where E: struct,Enum
            {
            return SqlEnumConverter<E>.ConvertFromObject(value,defaultvalue);
            }
        #endregion
        #region M:MemberType(MemberInfo):Type
        protected static Type MemberType(MemberInfo member) {
            if (member is FieldInfo    fi) { return fi.FieldType;    }
            if (member is PropertyInfo pi) { return pi.PropertyType; }
            throw new InvalidOperationException($"Unsupported member type: {member.GetType().FullName}");
            }
        #endregion
        #region M:CoerceValue(Type,TypeConverter,Object)
        protected virtual Object CoerceValue(Type typeT,TypeConverter converter,Object value) {
            var typeS = value?.GetType();
            if (value != null) {
                if (typeof(IEnumerable).IsAssignableFrom(typeS) &&
                    typeof(IEnumerable).IsAssignableFrom(typeT) &&
                    (typeT != typeof(Byte[])))
                    {
                    if (IsGenericCollection(typeS,out var typeSG,out var typeSE) &&
                        IsGenericCollection(typeT,out var typeTG,out var typeTE))
                        {
                        if (typeTG == typeof(IList<>)) {
                            var target = (IList)Activator.CreateInstance(typeof(List<>).MakeGenericType(typeTE));
                            foreach (var i in (IEnumerable)value) {
                                target.Add(CoerceValue(typeTE,null,i));
                                }
                            return target;
                            }
                        }
                    }
                }

            if (converter != null) {
                if ((typeS == null) || (!typeT.IsAssignableFrom(typeS))) {
                    try
                        {
                        if ((converter.GetType()==typeof(TypeConverter)) ||
                            (converter.GetType()==typeof(ReferenceConverter)))
                            {
                            if ((value == null) && (!typeT.IsValueType)) {
                                return null;
                                }
                            }
                        return converter.ConvertFrom(new SqlObjectTypeDescriptorContext(this,Context),CultureInfo.CurrentCulture,value) ?? value;
                        }
                    catch (Exception e)
                        {
                        e.Add("Converter",converter.GetType().FullName);
                        e.Add("SourceValue",value??"{null}");
                        e.AddIfNotEmpty("SourceType",value?.GetType().FullName);
                        e.Add("TargetType",typeT.FullName);
                        throw;
                        }
                    }
                }
            return value;
            }
        #endregion
        #region M:CoerceValue(PropertyDescriptor,Object):Object
        protected virtual Object CoerceValue(PropertyDescriptor descriptor,Object value) {
            var converter = descriptor.Converter;
            try
                {
                return CoerceValue(descriptor.PropertyType,converter,value);
                }
            catch (Exception e)
                {
                throw (new Exception($@"Error converting value for property ""{descriptor.ComponentType.Name}.{descriptor.Name}"".",e)).Add("Converter",converter?.GetType()?.Name);
                }
            }
        #endregion
        #region M:IsGenericCollection(Type,{out}Type,{out}Type):Boolean
        protected virtual Boolean IsGenericCollection(Type TypeI,out Type TypeG,out Type TypeE) {
            if (TypeI == null) { throw new ArgumentNullException(nameof(TypeI)); }
            TypeG = default;
            TypeE = default;
            var types = new[] {
                typeof(IList<>),
                typeof(ISet<>),
                typeof(ICollection<>),
                typeof(IEnumerable<>)
                };
            if (TypeI.IsConstructedGenericType) {
                var typeG = TypeI.GetGenericTypeDefinition();
                foreach (var type in types) {
                    if (type.IsAssignableFrom(typeG)) {
                        TypeG = typeG;
                        TypeE = TypeI.GenericTypeArguments[0];
                        return true;
                        }
                    }
                }

            var interfaces = new HashSet<Type>(TypeI.GetInterfaces());
            foreach (var type in types) {
                if (TryGetGenericCollectionDefinition(interfaces,type,out var typeE)) {
                    TypeG = type;
                    TypeE = typeE;
                    return true;
                    }
                }
            return false;
            }
        #endregion
        #region M:TryGetGenericCollectionDefinition(ISet<Type>,Type,{out}Type):Boolean
        protected static Boolean TryGetGenericCollectionDefinition(ISet<Type> Types,Type TypeG,out Type TypeE) {
            if (Types == null) { throw new ArgumentNullException(nameof(Types)); }
            TypeE = default;
            foreach (var type in Types) {
                if (type.IsConstructedGenericType) {
                    var typeG = type.GetGenericTypeDefinition();
                    if (typeG != null) {
                        if (typeG == TypeG) {
                            TypeE = type.GenericTypeArguments[0];
                            return true;
                            }
                        }
                    }
                }
            return false;
            }
        #endregion
        #region M:IsMatch(String,String):Boolean
        protected static Boolean IsMatch(String input,String pattern)
            {
            return Regex.IsMatch(input,pattern);
            }
        #endregion
        #region M:IsMatch(String,String,{out}Match):Boolean
        protected static Boolean IsMatch(String input,String pattern,out Match match)
            {
            match = Regex.Match(input,pattern);
            return match.Success;
            }
        #endregion
        #region M:GetService(Type):Object
        /// <summary>Gets the service object of the specified type.</summary>
        /// <param name="service">An object that specifies the type of service object to get.</param>
        /// <returns>A service object of type <paramref name="service"/>.
        /// -or-
        /// <see langword="null"/> if there is no service object of type <paramref name="service"/>.</returns>
        Object IServiceProvider.GetService(Type service) {
            return GetService(service);
            }
        /// <summary>Gets the service object of the specified type.</summary>
        /// <param name="service">An object that specifies the type of service object to get.</param>
        /// <returns>A service object of type <paramref name="service"/>.
        /// -or-
        /// <see langword="null"/> if there is no service object of type <paramref name="service"/>.</returns>
        protected virtual Object GetService(Type service) {
            if (service == GetType()) { return this; }
            return null;
            }
        #endregion
        #region M:GetService<T>:T
        /// <summary>Gets the service object of the specified type.</summary>
        /// <typeparam name="T">The type of service object to get.</typeparam>
        /// <returns>A service object of type <typeparamref name="T"/>.
        /// -or-
        /// <see langword="null"/> if there is no service object of type <typeparamref name="T"/>.</returns>
        public T GetService<T>()
            where T:class
            {
            return (T)GetService(typeof(T));
            }
        #endregion
        #region M:FormatLiteral(String):String
        protected virtual String FormatLiteral(String value)
            {
            if (value == null) { return String.Empty; }
            return value.Replace("'","''");
            }
        #endregion

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

        private abstract class PropertyDescriptor<T>: PropertyDescriptor
            where T: MemberInfo
            {
            protected T Source { get; }
            public override Type ComponentType { get{ return Source.DeclaringType; }}
            public override TypeConverter Converter { get {
                var type = PropertyType;
                if (type == typeof(Boolean )) { return SqlBooleanConverter.DoesNotAllowNull; }
                if (type == typeof(Boolean?)) { return SqlBooleanConverter.Default;          }
                if (type == typeof(Int32))    { return SqlInt32Converter.DoesNotAllowNull;   }
                if (type == typeof(Int32?))   { return SqlInt32Converter.Default;            }
                if (type == typeof(Int64))    { return SqlInt64Converter.DoesNotAllowNull;   }
                if (type == typeof(Int64?))   { return SqlInt64Converter.Default;            }
                var r = base.Converter;
                return r;
                }}

            #region ctor{T,String}
            protected PropertyDescriptor(T member,String name)
                : this(member,name,member.GetCustomAttributes())
                {
                }
            #endregion
            #region ctor{T,String,IEnumerable<Attribute>}
            protected PropertyDescriptor(T member,String name,IEnumerable<Attribute> attributes)
                : base(name,(attributes?.ToArray())??Array.Empty<Attribute>())
                {
                if (member == null) { throw new ArgumentNullException(nameof(member)); }
                if (name == null)   { throw new ArgumentNullException(nameof(name));   }
                Source = member;
                }
            #endregion

            #region M:CanResetValue(Object):Boolean
            /// <summary>When overridden in a derived class, returns whether resetting an object changes its value.</summary>
            /// <returns>true if resetting the component changes its value; otherwise, false.</returns>
            /// <param name="component">The component to test for reset capability.</param>
            public override Boolean CanResetValue(Object component)
                {
                return false;
                }
            #endregion
            #region M:CoerceValue(Object):Object
            protected Object CoerceValue(Object value) {
                if (value == null) {
                    var attribute = (SqlModelFieldMappingAttribute)Attributes[typeof(SqlModelFieldMappingAttribute)];
                    if ((attribute != null) && (attribute.EmptyIfNull)) {
                        if (PropertyType.IsConstructedGenericType) {
                            var typeG = PropertyType.GetGenericTypeDefinition();
                            if (typeof(IList<>).IsAssignableFrom(typeG)) {
                                var typeT = PropertyType.GenericTypeArguments[0];
                                return MakeReadOnlyList(typeT);
                                }
                            }
                        }
                    }
                return value;
                }
            #endregion
            #region M:MakeReadOnlyList(Type):Object
            private static Object MakeReadOnlyList(Type type) {
                var typeG = typeof(EmptyArray<>);
                var typeT = typeG.MakeGenericType(type);
                var fi = typeT.GetField("List",BindingFlags.Public|BindingFlags.Static);
                return fi?.GetValue(null);
                }
            #endregion
            #region M:ResetValue(Object)
            /// <summary>When overridden in a derived class, resets the value for this property of the component to the default value.</summary>
            /// <param name="component">The component with the property value that is to be reset to the default value.</param>
            public override void ResetValue(Object component)
                {
                throw new NotSupportedException();
                }
            #endregion
            #region M:ShouldSerializeValue(Object):Boolean
            /// <summary>When overridden in a derived class, determines a value indicating whether the value of this property needs to be persisted.</summary>
            /// <returns>true if the property should be persisted; otherwise, false.</returns>
            /// <param name="component">The component with the property to be examined for persistence.</param>
            public override Boolean ShouldSerializeValue(Object component)
                {
                return false;
                }
            #endregion
            #region M:ToString:String
            public override String ToString()
                {
                return Name;
                }
            #endregion
            }

        private class PropertyDescriptorP : PropertyDescriptor<PropertyInfo>
            {
            public override Type PropertyType { get { return Source.PropertyType; }}
            public override Boolean IsReadOnly { get { return false; }}

            #region ctor{PropertyInfo,String}
            private PropertyDescriptorP(PropertyInfo member,String name)
                : base(member,name)
                {
                }
            #endregion
            #region ctor{PropertyInfo}
            public PropertyDescriptorP(PropertyInfo member)
                : this(member,member.Name)
                {
                }
            #endregion

            #region M:GetValue(Object):Object
            public override Object GetValue(Object component)
                {
                throw new NotImplementedException();
                }
            #endregion
            #region M:SetValue(Object,Object)
            public override void SetValue(Object component,Object value) {
                if (component == null) { throw new ArgumentNullException(nameof(component)); }
                value = CoerceValue(value);
                Source.SetValue(component,(component is SqlObject target)
                    ? target.CoerceValue(this,value)
                    : value);
                }
            #endregion
            }

        private class PropertyDescriptorF : PropertyDescriptor<FieldInfo>
            {
            public override Type PropertyType { get { return Source.FieldType; }}
            public override Boolean IsReadOnly { get { return false; }}

            #region ctor{FieldInfo,String}
            public PropertyDescriptorF(FieldInfo member,String name,IEnumerable<Attribute> attributes)
                : base(member,name,attributes)
                {
                }
            #endregion
            #region ctor{FieldInfo}
            public PropertyDescriptorF(FieldInfo member)
                : base(member,member.Name)
                {
                }
            #endregion

            #region M:GetValue(Object):Object
            public override Object GetValue(Object component)
                {
                return Source.GetValue(component);
                }
            #endregion
            #region M:SetValue(Object,Object)
            public override void SetValue(Object component,Object value) {
                if (component == null) { throw new ArgumentNullException(nameof(component)); }
                value = CoerceValue(value);
                try
                    {
                    var FieldName = Source.Name;
                    Source.SetValue(component,(component is SqlObject target)
                        ? target.CoerceValue(this,value)
                        : value);
                    }
                catch (Exception e)
                    {
                    e.Add("PropertyName",Name);
                    e.Add("ComponentType",ComponentType.FullName);
                    throw;
                    }
                }
            #endregion
            }

        private class SqlObjectTypeDescriptorContext : ITypeDescriptorContext
            {
            public IServiceProvider Service { get; }
            public IContainer Container
                {
                get
                    {
                    return null;
                    }
                }

            public Object Instance { get; }

            public PropertyDescriptor PropertyDescriptor
                {
                get
                    {
                    return null;
                    }
                }

            public SqlObjectTypeDescriptorContext(Object Instance,IServiceProvider Service)
                {
                this.Instance = Instance;
                this.Service = Service;
                }
            public void OnComponentChanged()
                {
                }
            public bool OnComponentChanging()
                {
                return true;
                }
            public Object GetService(Type serviceType) {
                return Service?.GetService(serviceType);
                }
            }

        private static readonly IDictionary<Type,IDictionary<String,PropertyDescriptor>> PropertyMapping = new Dictionary<Type,IDictionary<String,PropertyDescriptor>>();
        private static readonly ReaderWriterLockSlim rwl = new ReaderWriterLockSlim();
        }
    }
