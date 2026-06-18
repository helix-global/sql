using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Drawing;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text;
using System.Xml;
using BinaryStudio.SqlServer.Infrastructure;
using JetBrains.Annotations;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal class FastReportSerializerSTD : Component,IFastReportSerializer
        {
        #region ctor{ISqlXmlWriter}
        public FastReportSerializerSTD(ISqlXmlWriter writer) {
            if (writer == null) { throw new ArgumentNullException(nameof(writer)); }
            this.writer = writer;
            }
        #endregion
        #region ctor{Stream}
        public FastReportSerializerSTD(Stream stream) {
            if (stream == null) { throw new ArgumentNullException(nameof(stream)); }
            this.stream = stream;
            this.writer = new FastReportXmlWriter(this.stream,new XmlWriterSettings {
                Indent = true,
                Encoding = Encoding.UTF8,
                OmitXmlDeclaration = false,
                });
            }
        #endregion

        #region M:IFastReportSerializer.Serialize<T>(T,String,Object)
        void IFastReportSerializer.Serialize<T>(T source,String prefix,Object other)
            {
            Serialize(source,prefix,other);
            }
        #endregion
        #region M:Dispose(Boolean)
        protected override void Dispose(Boolean disposing) {
            if (writer is IDisposable disposable) {
                disposable.Dispose();
                writer = null;
                }
            base.Dispose(disposing);
            }
        #endregion

        public void Serialize(FastReport source)
            {
            writer.WriteProcessingInstruction("xml","version=\"1.0\" encoding=\"utf-8\"");
            source.Serialize(this,null,null);
            writer.WriteWhitespace(Environment.NewLine);
            }

        #region M:Serialize<T>(T,String,Object)
        protected virtual void Serialize<T>(T source,String prefix,Object other)
            where T: FastReportObject,IFastReportClassObjectLegacy
            {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source,prefix);
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportInfo,String,Object)
        void IFastReportSerializer.Serialize(FastReportInfo source,String prefix,Object other) {
            SerializeAttributes(source,prefix);
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReport,String,Object)
        void IFastReportSerializer.Serialize(FastReport source,String prefix,Object other) {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source,prefix);
                if (!String.IsNullOrWhiteSpace(source.Script)) {
                    using (writer.ElementGroup("ScriptText")) {
                        writer.WriteRaw(EncodeString(source.Script));
                        }
                    if (source.Styles.Any()) {
                        using (writer.ElementGroup("Styles")) {
                            Serialize(source.Styles,prefix);
                            }
                        }
                    using (writer.ElementGroup("Dictionary")) {
                        Serialize(source.DataSources,prefix);
                        Serialize(source.Relations,prefix);
                        Serialize(source.Parameters,prefix);
                        Serialize(source.Totals,prefix);
                        }
                    Serialize(source.Children.ToArray(),prefix);
                    }
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportFormatBase,String,Object)
        void IFastReportSerializer.Serialize(FastReportFormatBase source,String prefix,Object other) {
            writer.WriteAttribute(prefix,FastReportFormatConverter.Instance.ConvertToInvariantString(source));
            SerializeAttributes(source,prefix);
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportFillBase,String,Object)
        void IFastReportSerializer.Serialize(FastReportFillBase source,String prefix,Object other) {
            if (other != null) {
                if (other.GetType() != source.GetType()) {
                    writer.WriteAttribute(prefix,FastReportFillConverter.Instance.ConvertToInvariantString(source));
                    }
                }
            else
                {
                writer.WriteAttribute(prefix,FastReportFillConverter.Instance.ConvertToInvariantString(source));
                }
            SerializeAttributes(source,prefix);
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportBorder,String,Object)
        void IFastReportSerializer.Serialize(FastReportBorder source,String prefix,Object other) {
            if (source.Shadow) { writer.WriteAttribute($"{prefix}.Shadow","true"); }
            if (source.ShadowWidth != 4f) { writer.WriteAttribute($"{prefix}.ShadowWidth",source.ShadowWidth); }
            if (source.ShadowColor != Color.Black) { writer.WriteAttribute($"{prefix}.ShadowColor",FastReportColorConverter.Instance.ConvertToInvariantString(source.ShadowColor)); }
            if (!source.SimpleBorder) {
                if (source.Lines > 0) {
                    writer.WriteAttribute($"{prefix}.Lines",source.Lines);
                    if (source.LeftLine.Equals(source.RightLine) && source.LeftLine.Equals(source.TopLine) && source.LeftLine.Equals(source.BottomLine)) {
                        source.LeftLine.Serialize(this,prefix,null);
                        return;
                        }
                    source.LeftLine.Serialize(this,$"{prefix}.LeftLine",null);
                    source.TopLine.Serialize(this,$"{prefix}.TopLine",null);
                    source.RightLine.Serialize(this,$"{prefix}.RightLine",null);
                    source.BottomLine.Serialize(this,$"{prefix}.BottomLine",null);
                    }
                }
            else
                {
                source.LeftLine.Serialize(this,prefix,null);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportBorderLine,String,Object)
        void IFastReportSerializer.Serialize(FastReportBorderLine source,String prefix,Object other) {
            SerializeAttributes(source,prefix);
            }
        #endregion

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

        #region M:Order(PropertyDescriptor):Int32
        private static Int32 Order(PropertyDescriptor descriptor) {
            var r = descriptor.Attributes.OfType<SqlObjectFieldMappingAttribute>().FirstOrDefault();
            return (r != null)
                ? r.Order
                : 0;
            }
        #endregion
        #region M:SerializeAttribute<T>(T,String,PropertyDescriptor)
        protected void SerializeAttribute<T>(T source,String prefix,PropertyDescriptor descriptor) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            if (descriptor == null) { throw new ArgumentNullException(nameof(descriptor)); }
            var value = descriptor.GetValue(source);
            if (IsDefaultValue(value,descriptor,out var defaultValue)) { return; }
            if (value == null) { return; }
            var field = descriptor.Attributes.OfType<SqlObjectFieldMappingAttribute>().FirstOrDefault();
            if (field != null) {
                var serializerAttribute = descriptor.Attributes.OfType<FastReportSerializerAttribute>().FirstOrDefault();
                if (serializerAttribute != null) {
                    var serializer = (IFastReportCustomSerializer)Activator.CreateInstance(serializerAttribute.SerializerType);
                    //serializer.Serialize(writer,this,descriptor);
                    return;
                    }
                var name = field.Source ?? descriptor.Name;
                if (value is FastReportObject fro) {
                    fro.Serialize(this,String.IsNullOrWhiteSpace(prefix)
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
        #region M:SerializeAttributes<T>(T,String)
        protected void SerializeAttributes<T>(T source,String prefix) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            foreach (var descriptor in TypeDescriptor.GetProperties(source)
                .Cast<PropertyDescriptor>()
                .Select(i=>new PropLink(i))
                .OrderBy(Order))
                {
                SerializeAttribute(source,prefix,descriptor);
                }
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
        #region M:Serialize(IEnumerable<T>,String)
        protected void Serialize<T>(IEnumerable<T> values,String prefix)
            where T:FastReportObject
            {
            if (values != null) {
                var children = values.ToArray();
                foreach(var o in children) {
                    o.Serialize(this,prefix,null);
                    }
                }
            }
        #endregion

        protected ISqlXmlWriter writer;
        protected Stream stream;
        }
    }
