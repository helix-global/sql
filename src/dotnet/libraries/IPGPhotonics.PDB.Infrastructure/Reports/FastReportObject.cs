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
    internal abstract class FastReportObject : SqlObject,IFastReportClassObjectLegacy,IFastReportClassObject
        {
        public const String URI_FR_NS = "urn:schemas.ipg.corp:pdb:fast-report";
        public const String URI_FR_PREFIX = "";

        #region P:Children:IEnumerable<FastReportObject>
        public virtual IEnumerable<FastReportObject> Children { get {
            foreach (var o in m_objects)
                {
                yield return o;
                }
            }}
        #endregion
        #region P:IFastReportClassObjectLegacy.ClassName:String
        String IFastReportClassObjectLegacy.ClassName { get {
            var type = GetType();
            return type.GetCustomAttribute<FastReportClassAttribute>(false)?.Name ?? type.Name;
            }}
        #endregion
        #region P:IFastReportClassObject.ClassName:String
        String IFastReportClassObject.ClassName { get {
            var type = GetType();
            return type.GetCustomAttribute<FastReportClassAttribute>(false)?.Name ?? type.Name;
            }}
        #endregion

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
        protected virtual void UpdateReferences(IList<FastReportObject> source) {
            using (var objects = PrepareChanges(m_objects)) {
                foreach (var o in source) {
                    objects.Add(o);
                    }
                }
            }
        #endregion
        #region M:Serialize(XmlWriter,String,Object)
        public virtual void Serialize(XmlWriter writer,String prefix,Object other) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            var className = ((IFastReportClassObjectLegacy)this).ClassName;
            using (writer.ElementGroup(className)) {
                SerializeAttributes(writer,prefix);
                Serialize(writer,Children,prefix);
                }
            }
        #endregion
        #region M:Serialize(XmlWriter,IEnumerable<T>,String)
        protected static void Serialize<T>(XmlWriter writer,IEnumerable<T> values,String prefix)
            where T:FastReportObject
            {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            if (values != null) {
                foreach(var o in values) {
                    o.Serialize(writer,prefix,null);
                    }
                }
            }
        #endregion
        #region M:SerializeAttributes(XmlWriter,String,Func<PropertyDescriptor,Boolean>)
        protected virtual void SerializeAttributes(XmlWriter writer,String prefix,Func<PropertyDescriptor,Boolean> predicate = null) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            foreach (var descriptor in TypeDescriptor.GetProperties(this).Cast<PropertyDescriptor>().Select(i=>new PropLink(i)).OrderBy(Order)) {
                if ((predicate == null) || predicate(descriptor)) {
                    SerializeAttribute(writer,prefix,descriptor);
                    }
                }
            }
        #endregion
        #region M:SerializeAttribute(XmlWriter,String,PropertyDescriptor)
        protected virtual void SerializeAttribute(XmlWriter writer,String prefix,PropertyDescriptor descriptor) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            if (descriptor == null) { throw new ArgumentNullException(nameof(descriptor)); }
            var value = descriptor.GetValue(this);
            if (IsDefaultValue(value,descriptor,out var defaultValue)) { return; }
            if (value == null) { return; }
            var field = descriptor.Attributes.OfType<SqlObjectFieldMappingAttribute>().FirstOrDefault();
            if (field != null) {
                var serializerAttribute = descriptor.Attributes.OfType<FastReportSerializerAttribute>().FirstOrDefault();
                if (serializerAttribute != null) {
                    var serializer = (IFastReportSerializer)Activator.CreateInstance(serializerAttribute.SerializerType);
                    serializer.Serialize(writer,this,descriptor);
                    return;
                    }
                var name = field.Source ?? descriptor.Name;
                if (value is FastReportObject fro) {
                    fro.Serialize(writer,String.IsNullOrWhiteSpace(prefix)
                        ? $"{name}"
                        : $"{prefix}.{name}",defaultValue);
                    return;
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
        #endregion
        #region M:Order(PropertyDescriptor):Int32
        private static Int32 Order(PropertyDescriptor descriptor) {
            var r = descriptor.Attributes.OfType<SqlObjectFieldMappingAttribute>().FirstOrDefault();
            return (r != null)
                ? r.Order
                : 0;
            }
        #endregion
        #region M:IsDefaultValue(Object,PropertyDescriptor,{out}Object):Boolean
        private static Boolean IsDefaultValue(Object value,PropertyDescriptor descriptor,out Object o) {
            o = default;
            var defaultValue = descriptor.Attributes.OfType<DefaultValueAttribute>().FirstOrDefault();
            if (defaultValue != null) {
                o = defaultValue.Value;
                if (Equals(value,defaultValue.Value)) { return true; }
                if (defaultValue.Value is String S) {
                    var converter = descriptor.Converter??TypeDescriptor.GetConverter(descriptor.PropertyType);
                    if (converter != null && converter.CanConvertFrom(typeof(String))) {
                        try
                            {
                            var r = converter.ConvertFromInvariantString(S);
                            if (Equals(value,r)) { return true; }
                            }
                        catch (Exception e)
                            {
                            throw (new Exception($@"Error converting default value ""{S}"" for property ""{descriptor.Name}"" of type ""{descriptor.PropertyType.FullName}"".",e)).Add("Property",descriptor.Name).Add("Type",descriptor.PropertyType.FullName).Add("DefaultValue",S);
                            }
                        }
                    }
                if (defaultValue.Value is FastReportDefaultValueSource DefaultValueSource) {
                    switch (DefaultValueSource) {
                        case FastReportDefaultValueSource.DefaultConstructor:
                            {
                            return Equals(value,o = Activator.CreateInstance(descriptor.PropertyType));
                            }
                        }
                    }
                return false;
                }
            if (descriptor.PropertyType.IsValueType) { return Equals(value,o = Activator.CreateInstance(descriptor.PropertyType)); }
            return false;
            }
        #endregion
        #region M:EncodeString(String):String
        protected static String EncodeString(String value) {
            if (String.IsNullOrEmpty(value)) { return value; }
            return value.
                Replace("&","&amp;").
                Replace("<","&lt;").
                Replace(">","&gt;").
                Replace("\"","&quot;");
            }
        #endregion
        #region M:WriteXml(ISqlXmlWriter)
        public override void WriteXml(ISqlXmlWriter writer) {
            using (writer.ElementGroup(URI_FR_PREFIX,((IFastReportClassObject)(this)).ClassName,URI_FR_NS)) {
                var properties = TypeDescriptor.GetProperties(this).Cast<PropertyDescriptor>().OrderBy(Order);
                var propA = new List<PropertyDescriptor>();
                var propE = new List<PropertyDescriptor>();
                foreach (var pi in properties) {
                    if (pi.PropertyType.IsSubclassOf(typeof(FastReportObject))) {
                        propE.Add(pi);
                        }
                    else
                        {
                        propA.Add(pi);
                        }
                    }
                WriteXmlA(writer,propA);
                WriteXmlE(writer,propE);
                var objects = Children?.ToArray();
                if ((objects != null) && (objects.Length > 0)) {
                    foreach (var o in objects) {
                        o.WriteXml(writer);
                        }
                    }
                }
            }
        #endregion
        #region M:WriteXmlA(ISqlXmlWriter,IList<PropertyDescriptor>)
        protected virtual void WriteXmlA(ISqlXmlWriter writer,IList<PropertyDescriptor> descriptors) {
            foreach (var descriptor in descriptors) {
                WriteXmlA(writer,descriptor);
                }
            }
        #endregion
        #region M:WriteXmlE(ISqlXmlWriter,IList<PropertyDescriptor>)
        protected virtual void WriteXmlE(ISqlXmlWriter writer,IList<PropertyDescriptor> descriptors) {
            foreach (var descriptor in descriptors) {
                WriteXmlE(writer,descriptor);
                }
            }
        #endregion
        #region M:WriteXmlE(ISqlXmlWriter,PropertyDescriptor)
        protected virtual void WriteXmlA(ISqlXmlWriter writer,PropertyDescriptor descriptor) {
            var value = descriptor.GetValue(this);
            if (IsDefaultValue(value,descriptor,out var defaultValue)) { return; }
            if (value == null) { return; }
            var converter = descriptor.Converter??TypeDescriptor.GetConverter(descriptor.PropertyType);
            if (converter != null && converter.CanConvertTo(typeof(String))) {
                value = converter.ConvertToInvariantString(value);
                writer.WriteAttribute($"{descriptor.Name}",value);
                }
            }
        #endregion
        #region M:WriteXmlE(ISqlXmlWriter,PropertyDescriptor)
        protected virtual void WriteXmlE(ISqlXmlWriter writer,PropertyDescriptor descriptor) {
            var value = descriptor.GetValue(this);
            if (IsDefaultValue(value,descriptor,out var defaultValue)) { return; }
            if (value == null) { return; }
            using (writer.ElementGroup(URI_FR_PREFIX,$"{((IFastReportClassObject)(this)).ClassName}.{descriptor.Name}",URI_FR_NS)) {
                if (value is SqlObject o) {
                    o.WriteXml(writer);
                    return;
                    }
                var converter = descriptor.Converter??TypeDescriptor.GetConverter(descriptor.PropertyType);
                if (converter != null && converter.CanConvertTo(typeof(String))) {
                    value = converter.ConvertToInvariantString(value);
                    writer.WriteString(value?.ToString());
                    }
                }
            }
        #endregion

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
            #region M:ToString:String
            public override String ToString()
                {
                return $"{Name}";
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

        private IList<FastReportObject> m_objects { get; } = new SqlObjectCollection<FastReportObject>();
        }
    }
