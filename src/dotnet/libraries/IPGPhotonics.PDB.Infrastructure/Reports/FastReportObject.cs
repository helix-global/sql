using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.Collections.ObjectModel;
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal abstract class FastReportObject : SqlObject,IFastReportVisitable
        {
        public virtual IEnumerable<FastReportObject> Children { get { return EmptyArray<FastReportObject>.List; }}
        protected internal virtual String ClassName { get; }

        #region M:ResolveMappings(Object,{out}IDictionary<String,PropertyDescriptor>)
        private static void ResolveMappings(Object source,out IDictionary<String,PropertyDescriptor> mapping) {
            if (source is SqlObject) {
                ResolveFieldMappings(source.GetType(),out mapping);
                }
            else
                {
                mapping = TypeDescriptor.GetProperties(source).
                    OfType<PropertyDescriptor>().
                    Select(i=>(PropertyDescriptor)new PropDesc(i)).
                    ToDictionary(i=>i.Name,i=>i);
                }
            }
        #endregion
        #region M:Store(IDictionary<String,PropInfo>,IReadOnlyList<String>,String,Int32?)
        private static void Store(IDictionary<String,PropInfo> storage,IReadOnlyList<String> key,String value,Int32? lineNumber) {
            switch (key.Count) {
                case 1:
                    storage[key[0]] = new PropInfo(value) {
                        LineNumber = lineNumber
                        };
                    break;
                default:
                    {
                    if (!storage.TryGetValue(key[0],out var pi)) {
                        storage[key[0]] = pi = new PropInfo();
                        }
                    Store(pi.Children,key.Skip(1).ToArray(),value,lineNumber);
                    }
                    break;
                }
            }
        #endregion
        #region M:Apply(FastReportObject,IDictionary<String,PropInfo>)
        private static void Apply(Object source,IDictionary<String,PropInfo> storage) {
            ResolveMappings(source,out var mapping);
            foreach (var pi in storage) {
                if (!mapping.TryGetValue(pi.Key, out var mi)) {
                    throw new NotSupportedException(
                        (pi.Value.LineNumber != null)
                        ? $@"[Line={pi.Value.LineNumber}] @Attribute=""{pi.Key}"" with value ""{pi.Value}"" is not supported for ""{source.GetType().FullName}""."
                        : $@"@Attribute=""{pi.Key}"" with value ""{pi.Value}"" is not supported for ""{source.GetType().FullName}""."
                        );
                    }
                if (pi.Value.Value != null) {
                    if (source is FastReportObject o)
                        {
                        o.SetValue(mi,pi.Value.Value);
                        }
                    else
                        {
                        mi.SetValue(source,pi.Value.Value);
                        }
                    }
                if (pi.Value.Children.Any()) {
                    var target = mi.GetValue(source);
                    Apply(target,pi.Value.Children);
                    }
                }
            }
        #endregion
        #region M:ReadXmlA(XmlReader)
        protected override void ReadXmlA(XmlReader reader) {
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            var storage = new Dictionary<String,PropInfo>();
            while (reader.MoveToNextAttribute()) {
                Store(storage,reader.LocalName.Split('.'),
                    reader.Value,(reader as IXmlLineInfo)?.LineNumber);
                }
            Apply(this,storage);
            }
        #endregion
        #region M:ReadXmlE(XmlReader)
        protected override void ReadXmlE(XmlReader reader) {
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            ResolveFieldMappings(GetType(),out var mapping);
            var objects = new List<FastReportObject>();
            ForEachE(reader,(_)=>{
                if (mapping.TryGetValue(reader.Name,out var pi)) {
                    if (IsGenericCollection(pi.PropertyType,out var TypeG,out var TypeE)){
                        var target = (IList)Activator.CreateInstance(typeof(List<>).MakeGenericType(TypeE));
                        using (var r = reader.ReadSubtree()) {
                            r.MoveToContent();
                            ForEachE(r,(__)=>{
                                CreateE(r,out var obj);
                                target.Add(obj);
                                });
                            }
                        target = (IList)Activator.CreateInstance(typeof(ReadOnlyCollection<>).MakeGenericType(TypeE),target);
                        SetValue(pi,target);
                        return;
                        }
                    }
                CreateE(reader,out var o);
                objects.Add(o);
                });
            UpdateReferences(objects);
            }
        #endregion
        #region M:CreateE(XmlReader)
        protected virtual void CreateE(XmlReader reader) {
            CreateE(reader,out _);
            }
        #endregion
        #region M:CreateE(XmlReader,{out}FastReportObject)
        protected virtual void CreateE(XmlReader reader,out FastReportObject o) {
            if (reader == null) { throw new ArgumentNullException(nameof(reader)); }
            o = CreateObject(reader.Name);
            if (o != null) {
                using (var r = reader.ReadSubtree()) {
                    o.ReadXml(r);
                    reader.Skip();
                    }
                return;
                }
            throw new NotSupportedException(
                (reader is IXmlLineInfo LineInfo)
                ? $@"[Line={LineInfo.LineNumber}] Element <{reader.Name}> is not supported for ""{GetType().FullName}""."
                : $@"<{reader.Name}> is not supported for ""{GetType().FullName}""."
                );
            }
        #endregion
        #region M:CreateObject(String):FastReportObject
        protected virtual FastReportObject CreateObject(String typeName) {
            if (RegisteredTypes.TryGetValue(typeName,out var type)) {
                return (FastReportObject)Activator.CreateInstance(type,nonPublic: true);
                }
            return null;
            }
        #endregion
        #region M:UpdateReferences(IList<FastReportObject>)
        protected virtual void UpdateReferences(IList<FastReportObject> source)
            {
            }
        #endregion
        #region M:Serialize(XmlWriter,String)
        public virtual void Serialize(XmlWriter writer,String prefix) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            var type = GetType();
            var className = type.GetCustomAttribute<FastReportClassAttribute>(false)?.Name ?? type.Name;
            using (writer.ElementGroup(className)) {
                SerializeAttributes(writer,this,prefix);
                foreach (var o in Children) {
                    o.Serialize(writer,prefix);
                    }
                }
            }
        #endregion
        #region M:Serialize(XmlWriter,IEnumerable<T>,String)
        protected static void Serialize<T>(XmlWriter writer,IEnumerable<T> values,String prefix)
            where T:FastReportObject
            {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            foreach(var o in values) {
                o.Serialize(writer,prefix);
                }
            }
        #endregion
        #region M:SerializeAttributes(XmlWriter,Object,String,Func<PropertyDescriptor,Boolean>)
        protected static void SerializeAttributes(XmlWriter writer,Object source,String prefix,Func<PropertyDescriptor,Boolean> predicate = null) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            foreach (var descriptor in TypeDescriptor.GetProperties(source).Cast<PropertyDescriptor>().Select(i=>new PropLink(i)).OrderBy(Order)) {
                if ((predicate == null) || predicate(descriptor)) {
                    var value = descriptor.GetValue(source);
                    if (IsDefaultValue(value,descriptor)) { continue; }
                    if (value == null) { continue; }
                    var field = descriptor.Attributes.OfType<SqlObjectFieldMappingAttribute>().FirstOrDefault();
                    if (field != null) {
                        var name = field.Source ?? descriptor.Name;
                        if (value is FastReportObject fro) {
                            fro.Serialize(writer,name);
                            continue;
                            }
                        var converter = descriptor.Converter??TypeDescriptor.GetConverter(descriptor.PropertyType);
                        if (converter != null && converter.CanConvertTo(typeof(String))) {
                            value = converter.ConvertToInvariantString(value);
                            writer.WriteAttribute(String.IsNullOrWhiteSpace(prefix)
                                ? $"{name}"
                                : $"{prefix}.{name}",value);
                            }
                        }
                    }
                }
            }
        #endregion
        #region M:Order(PropertyDescriptor):Int32
        private static Int32 Order(PropertyDescriptor descriptor) {
            var r = descriptor.Attributes.OfType<SqlObjectFieldMappingAttribute>().FirstOrDefault();
            return (r != null)
                ? r.Order
                : 0;
            }
        #endregion
        #region M:IsDefaultValue(Object,PropertyDescriptor):Boolean
        private static Boolean IsDefaultValue(Object value,PropertyDescriptor descriptor) {
            var defaultValue = descriptor.Attributes.OfType<DefaultValueAttribute>().FirstOrDefault();
            if (defaultValue != null) { return Equals(value,defaultValue.Value); }
            if (descriptor.PropertyType.IsValueType) { return Equals(value,Activator.CreateInstance(descriptor.PropertyType)); }
            return false;
            }
        #endregion
        #region M:EncodeString(String):String
        protected static String EncodeString(String value) {
            if (String.IsNullOrEmpty(value)) { return value; }
            return value.
                Replace("<","&lt;").
                Replace(">","&gt;").
                Replace("\"","&quot;").
                Replace("'","&apos;");
            }
        #endregion

        public virtual void Accept(IFastReportVisitor visitor) { }

        private class PropInfo
            {
            public String Value { get; }
            public Int32? LineNumber { get;set; }
            public IDictionary<String,PropInfo> Children { get; } = new Dictionary<String,PropInfo>();

            #region ctor
            public PropInfo()
                {
                Value = null;
                }
            #endregion
            #region ctor{String}
            public PropInfo(String value)
                {
                Value = value;
                }
            #endregion
            #region M:ToString:String
            /// <summary>Returns a string that represents the current object.</summary>
            /// <returns>A string that represents the current object.</returns>
            public override String ToString()
                {
                return Value;
                }
            #endregion
            }

        private class PropDesc : PropertyDescriptor
            {
            #region ctor{String,Attribute[]}
            public PropDesc([NotNull] String name,Attribute[] attrs)
                : base(name,attrs)
                {
                }
            #endregion
            #region ctor{PropertyDescriptor}
            public PropDesc([NotNull] PropertyDescriptor descr)
                : base(descr)
                {
                this.descr = descr;
                }
            #endregion
            #region ctor{MemberDescriptor,Attribute[]}
            public PropDesc([NotNull] MemberDescriptor descr,Attribute[] attrs)
                : base(descr,attrs)
                {
                }
            #endregion

            #region M:CanResetValue(Object):Boolean
            public override Boolean CanResetValue(Object component)
                {
                return descr.CanResetValue(component);
                }
            #endregion
            #region M:GetValue(Object):Object
            public override Object GetValue(Object component)
                {
                return descr.GetValue(component);
                }
            #endregion
            #region M:ResetValue(Object)
            public override void ResetValue(Object component)
                {
                descr.ResetValue(component);
                }
            #endregion
            #region M:SetValue(Object,Object)
            /// <summary>Sets the value of the component to a different value.</summary>
            /// <param name="component">The component with the property value that is to be set.</param>
            /// <param name="value">The new value.</param>
            public override void SetValue(Object component,Object value) {
                if (value != null) {
                    var converter = Converter;
                    if (converter != null) {
                        if (converter.CanConvertFrom(value.GetType())) {
                            value = converter.ConvertFrom(value);
                            }
                        }
                    }
                descr.SetValue(component,value);
                }
            #endregion
            #region M:ShouldSerializeValue(Object):Boolean
            public override Boolean ShouldSerializeValue(Object component)
                {
                return descr.ShouldSerializeValue(component);
                }
            #endregion

            public override Type ComponentType { get { return descr.ComponentType; }}
            public override Boolean IsReadOnly { get { return descr.IsReadOnly;    }}
            public override Type PropertyType  { get { return descr.PropertyType;  }}

            private readonly PropertyDescriptor descr;
            }

        private class PropLink: PropDesc
            {
            public SqlStringOptionCollection ConverterParameter { get; } = SqlStringOptionCollection.Empty;
            public CultureInfo ConverterCulture { get; } = CultureInfo.CurrentCulture;

            #region P:Converter:TypeConverter
            public override TypeConverter Converter { get {
                if (m_cI != null) { return m_cI; }
                if (m_cT != null) {
                    var target = Activator.CreateInstance(m_cT);
                    if (target != null) {
                        var properties = TypeDescriptor.GetProperties(target).OfType<PropertyDescriptor>().ToDictionary(i=>i.Name,i=>i);
                        foreach (var option in ConverterParameter) {
                            if (properties.TryGetValue(option.Key,out var descriptor)) {
                                try
                                    {
                                    var value  = descriptor.Converter.ConvertTo(null,ConverterCulture,option.Value,descriptor.PropertyType);
                                    descriptor.SetValue(target,value);
                                    }
                                catch (Exception e)
                                    {
                                    throw (new Exception($@"Error setting converter option ""{option.Key}"" on converter ""{target.GetType().FullName}"".",e)).Add("Converter",target.GetType().FullName).Add("OptionKey",option.Key).Add("OptionValue",option.Value);
                                    }
                                }
                            }
                        return m_cI=(TypeConverter)target;
                        }
                    }
                if (PropertyType == typeof(Boolean)) { return FastReportBooleanConverter.Instance; }
                return base.Converter;
                }}
            #endregion

            #region ctor{PropertyDescriptor}
            public PropLink(PropertyDescriptor descr)
                : base(descr)
                {
                var attribute = (SqlObjectFieldMappingAttribute)Attributes[typeof(SqlObjectFieldMappingAttribute)];
                if (attribute != null) {
                    m_cT = attribute.Converter;
                    if (attribute.ConverterCulture != null) {
                        ConverterCulture = CultureInfo.GetCultureInfo(attribute.ConverterCulture ?? CultureInfo.CurrentCulture.Name);
                        }
                    ConverterParameter = new SqlStringOptionCollection(attribute.ConverterParameter);
                    }
                }
            #endregion

            private Type m_cT;
            private TypeConverter m_cI;
            }

        protected static readonly IDictionary<String,Type> RegisteredTypes = new ConcurrentDictionary<String,Type>();
        static FastReportObject() {
            foreach (var type in typeof(FastReportObject).Assembly.GetTypes()) {
                var attributes = type.GetCustomAttributes<FastReportClassAttribute>(inherit: false).ToArray();
                if (attributes.Length > 0) {
                    foreach (var attribute in attributes)
                        {
                        RegisteredTypes.Add(attribute.Name,type);
                        }
                    }
                }
            }
        }
    }
