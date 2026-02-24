using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
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

        #region M:ResolveAttributeMappings<T>(Type):IEnumerable<KeyValuePair<String,MemberInfo>>
        protected static IEnumerable<KeyValuePair<String,MemberInfo>> ResolveAttributeMappings<T>(Type Type)
            where T: Attribute,ISqlModelMappingAttribute
            {
            if (Type == null) { throw new ArgumentNullException(nameof(Type)); }
            foreach (var o in Type.GetFields(BindingFlags.FlattenHierarchy|BindingFlags.Instance|BindingFlags.NonPublic|BindingFlags.Public)) {
                var attribute = o.GetCustomAttribute<T>();
                if (attribute != null) {
                    yield return new KeyValuePair<String,MemberInfo>(attribute.SourceName??o.Name,o);
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
                            FieldInfo fi = null;
                            do
                                {
                                fi = type.GetField($"<{o.Name}>k__BackingField",BindingFlags.Instance|BindingFlags.NonPublic);
                                if (fi != null) { break; }
                                type = type.BaseType;
                                }
                            while (type != null);
                            if (fi != null)
                                {
                                yield return new KeyValuePair<String,MemberInfo>(attribute.SourceName??o.Name,fi);
                                continue;
                                }
                            }
                        }
                    yield return new KeyValuePair<String,MemberInfo>(attribute.SourceName??o.Name,o);
                    }
                }
            }
        #endregion
        #region M:ResolveFieldMappings(Type,{out}IDictionary<String,MInfo>)
        protected static void ResolveFieldMappings(Type Type,out IDictionary<String,MemberInfo> mapping) {
            if (Type == null) { throw new ArgumentNullException(nameof(Type)); }
            mapping = default;
            using (UpgradeableReadLock(rwl)) {
                if (!PropertyMapping.TryGetValue(Type, out mapping)) {
                    using (WriteLock(rwl)) {
                        PropertyMapping.Add(Type,mapping = new Dictionary<String,MemberInfo>());
                        foreach (var i in ResolveAttributeMappings<SqlModelFieldMappingAttribute>(Type)) {
                            mapping[i.Key] = i.Value;
                            }
                        }
                    }
                }
            }
        #endregion
        #region M:ApplyProperties(IDictionary<String,MemberInfo>,IDictionary<String,Object>)
        private void ApplyProperties(IDictionary<String,MemberInfo> mapping,IDictionary<String,Object> source) {
            if (mapping == null) { throw new ArgumentNullException(nameof(mapping)); }
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            foreach (var i in mapping) {
                if (source.TryGetValue(i.Key,out var o)) {
                    SetValue(i.Value,o);
                    }
                }
            }
        #endregion
        #region M:ApplyProperties(IDictionary<String,MemberInfo>,IDataRecord)
        private void ApplyProperties(IDictionary<String,MemberInfo> mapping,IDataRecord source) {
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
        #region M:ApplyProperties(IDictionary<String,MemberInfo>,DataRow)
        private void ApplyProperties(IDictionary<String,MemberInfo> mapping,DataRow source) {
            if (mapping == null) { throw new ArgumentNullException(nameof(mapping)); }
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            var type = GetType();
            foreach (var i in mapping) {
                if (source.Table.Columns.Contains(i.Key)) {
                    SetValue(i.Value,source[i.Key]);
                    }
                }
            }
        #endregion
        #region M:SetValue(MemberInfo,Object)
        protected virtual void SetValue(MemberInfo member,Object value) {
            if (member == null) { throw new ArgumentNullException(nameof(member)); }
            if (value is DBNull) { value = null; }
            if (member is FieldInfo fi)
                {
                SetValue(fi,value,GetConverter(fi));
                }
            else if (member is PropertyInfo pi)
                {
                SetValue(pi,value,GetConverter(pi));
                }
            else
                {
                throw new InvalidOperationException($"Unsupported member type: {member.GetType().FullName}");
                }
            }
        #endregion
        #region M:GetConverter(MemberInfo):TypeConverter
        private static TypeConverter GetConverter(MemberInfo mi) {
            if (mi != null) {
                var attribute = mi.GetCustomAttribute<TypeConverterAttribute>();
                if (attribute != null) {
                    var converterType = Type.GetType(attribute.ConverterTypeName);
                    if (converterType != null) {
                        return (TypeConverter)Activator.CreateInstance(converterType);
                        }
                    }
                }
            return null;
            }
        #endregion
        #region M:GetConverter(Type):TypeConverter
        private static TypeConverter GetConverter(Type type) {
                 if (type == typeof(Boolean )) { return SqlBooleanConverter.DoesNotAllowNull; }
            else if (type == typeof(Boolean?)) { return SqlBooleanConverter.Default;          }
            else if (type == typeof(Int32))    { return SqlInt32Converter.DoesNotAllowNull;   }
            else if (type == typeof(Int32?))   { return SqlInt32Converter.Default;            }
            else if (type == typeof(Int64))    { return SqlInt64Converter.DoesNotAllowNull;   }
            else if (type == typeof(Int64?))   { return SqlInt64Converter.Default;            }
            return GetConverter((MemberInfo)type) ?? TypeDescriptor.GetConverter(type);
            }
        #endregion
        #region M:GetConverter(FieldInfo):TypeConverter
        private static TypeConverter GetConverter(FieldInfo fi) {
            return (fi != null)
                ? GetConverter((MemberInfo)fi) ?? GetConverter(fi.FieldType)
                : null;
            }
        #endregion
        #region M:GetConverter(PropertyInfo):TypeConverter
        private static TypeConverter GetConverter(PropertyInfo fi) {
            return (fi != null)
                ? GetConverter((MemberInfo)fi) ?? GetConverter(fi.PropertyType)
                : null;
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
        #region M:SetValue(PropertyInfo,Object,TypeConverter)
        private void SetValue(PropertyInfo pi,Object value,TypeConverter converter) {
            if (converter != null) {
                var type = value?.GetType();
                if ((type == null) || (!pi.PropertyType.IsAssignableFrom(type))) {
                    try
                        {
                        var o = converter.ConvertFrom(value) ?? value;
                        SetValue(pi,o,null);
                        return;
                        }
                    catch (Exception e)
                        {
                        e.Data["Converter"] = converter.GetType().FullName;
                        throw;
                        }
                    }
                }
            try
                {
                pi.SetValue(this,value);
                }
            catch(Exception e)
                {
                throw;
                }
            }
        #endregion
        #region M:SetValue(FieldInfo,Object,TypeConverter)
        private void SetValue(FieldInfo fi,Object value,TypeConverter converter) {
            if (converter != null) {
                var type = value?.GetType();
                if ((type == null) || (!fi.FieldType.IsAssignableFrom(type))) {
                    try
                        {
                        var o = converter.ConvertFrom(value) ?? value;
                        SetValue(fi,o,null);
                        return;
                        }
                    catch (Exception e)
                        {
                        e.Data["Converter"] = converter.GetType().FullName;
                        throw;
                        }
                    }
                }
            try
                {
                fi.SetValue(this,value);
                }
            catch(Exception e)
                {
                throw;
                }
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

        private static readonly IDictionary<Type,IDictionary<String,MemberInfo>> PropertyMapping = new Dictionary<Type,IDictionary<String,MemberInfo>>();
        private static readonly ReaderWriterLockSlim rwl = new ReaderWriterLockSlim();
        }
    }
