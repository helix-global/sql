using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;
using System.Threading;
using System.Xml;
using System.Xml.Schema;
using System.Xml.Serialization;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public abstract class SqlModelObject : IXmlSerializable
        {
        #region ctor
        protected SqlModelObject()
            {
            }
        #endregion
        #region ctor{IDictionary<String,Object>}
        protected SqlModelObject(IDictionary<String,Object> source) {
            if (source != null) {
                ResolveFieldMappings(GetType(),out var mapping);
                ApplyProperties(mapping,source);
                }
            }
        #endregion
        #region ctor{DataRow}
        protected SqlModelObject(DataRow source) {
            if (source != null) {
                ResolveFieldMappings(GetType(),out var mapping);
                ApplyProperties(mapping,source);
                }
            }
        #endregion
        #region ctor{IDataRecord}
        protected SqlModelObject(IDataRecord source) {
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
                    yield return new KeyValuePair<String,PropertyDescriptor>(attribute.SourceName??o.Name,new PropertyDescriptorF(o));
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
                                    attribute.SourceName??o.Name,
                                    new PropertyDescriptorF(fi,o.Name,o.GetCustomAttributes()));
                                continue;
                                }
                            }
                        }
                    yield return new KeyValuePair<String,PropertyDescriptor>(
                        attribute.SourceName??o.Name,new PropertyDescriptorP(o));
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
        #region M:SetValue(PropertyDescriptor,Object)
        protected virtual void SetValue(PropertyDescriptor descriptor,Object value) {
            if (descriptor == null) { throw new ArgumentNullException(nameof(descriptor)); }
            if (value is DBNull) { value = null; }
            descriptor.SetValue(this,value);
            }
        #endregion
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
        #region M:IXmlSerializable.WriteXml(XmlWriter)
        /// <summary>Converts an object into its XML representation.</summary>
        /// <param name="writer">The <see cref="T:System.Xml.XmlWriter"/> stream to which the object is serialized.</param>
        void IXmlSerializable.WriteXml(XmlWriter writer)
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
        #region M:PropSI4(Object):Int32?
        protected static Int32? PropSI4(Object value) {
            return SqlInt32Converter.ConvertFromObject(value);
            }
        #endregion
        #region M:MemberType(MemberInfo):Type
        protected static Type MemberType(MemberInfo member) {
            if (member is FieldInfo    fi) { return fi.FieldType;    }
            if (member is PropertyInfo pi) { return pi.PropertyType; }
            throw new InvalidOperationException($"Unsupported member type: {member.GetType().FullName}");
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

        private abstract class  PropertyDescriptor<T>: PropertyDescriptor
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
            #region M:ConvertValue(Object):Object
            protected Object ConvertValue(Object value) {
                var converter = Converter;
                if (converter != null) {
                    var type = value?.GetType();
                    if ((type == null) || (!PropertyType.IsAssignableFrom(type))) {
                        try
                            {
                            return converter.ConvertFrom(value) ?? value;
                            }
                        catch (Exception e)
                            {
                            e.Data["Converter"] = converter.GetType().FullName;
                            throw new Exception($@"Error converting value for property ""{ComponentType.Name}.{Name}"".");
                            }
                        }
                    }
                return value;
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
                Source.SetValue(component,ConvertValue(value));
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
                Source.SetValue(component,ConvertValue(value));
                }
            #endregion
            }

        private static readonly IDictionary<Type,IDictionary<String,PropertyDescriptor>> PropertyMapping = new Dictionary<Type,IDictionary<String,PropertyDescriptor>>();
        private static readonly ReaderWriterLockSlim rwl = new ReaderWriterLockSlim();
        }
    }
