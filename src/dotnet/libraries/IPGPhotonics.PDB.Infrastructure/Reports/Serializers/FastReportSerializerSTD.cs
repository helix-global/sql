using System;
using System.Collections;
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
            disposeWriter = false;
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
            disposeWriter = true;
            }
        #endregion

        #region M:Serialize(FastReport)
        public virtual void Serialize(FastReport source)
            {
            writer.WriteProcessingInstruction("xml","version=\"1.0\" encoding=\"utf-8\"");
            source.Serialize(this,null,null);
            writer.WriteWhitespace(Environment.NewLine);
            }
        #endregion
        #region M:Serialize<T>(T,String,Object)
        protected virtual void Serialize<T>(T source,String prefix,Object other)
            where T: FastReportObject,IFastReportClassObjectLegacy
            {
            SerializeElement(source,prefix,other);
            }
        #endregion
        #region M:IFastReportSerializer.Serialize<T>(T,String,Object)
        void IFastReportSerializer.Serialize<T>(T source,String prefix,Object other)
            {
            Serialize(source,prefix,other);
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
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportBandColumns,String,Object)
        void IFastReportSerializer.Serialize(FastReportBandColumns source,String prefix,Object other) {
            SerializeAttributes(source,prefix);
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportBarcodeBase,String,Object)
        void IFastReportSerializer.Serialize(FastReportBarcodeBase source,String prefix,Object other) {
            if (other != null) {
                if (other.GetType() != source.GetType()) {
                    writer.WriteAttributeString(prefix,FastReportBarcodeConverter.Instance.ConvertToInvariantString(source));
                    }
                }
            else
                {
                writer.WriteAttributeString(prefix,FastReportBarcodeConverter.Instance.ConvertToInvariantString(source));
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
        #region M:IFastReportSerializer.Serialize(FastReportCapSettings,String,Object)
        void IFastReportSerializer.Serialize(FastReportCapSettings source,String prefix,Object other) {
            SerializeAttributes(source,prefix);
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportChartObject,String,Object)
        void IFastReportSerializer.Serialize(FastReportChartObject source,String prefix,Object other)
            {
            Serialize(source,prefix,other);
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportCurrencyFormat,String,Object)
        void IFastReportSerializer.Serialize(FastReportCurrencyFormat source,String prefix,Object other) {
            writer.WriteAttributeString(prefix,FastReportFormatConverter.Instance.ConvertToInvariantString(source));
            if (source.UseLocale) {
                writer.WriteAttributeString($"{prefix}.UseLocale","true");
                return;
                }
            writer.WriteAttributeString($"{prefix}.UseLocale","false");
            writer.WriteAttributeString($"{prefix}.DecimalDigits",source.DecimalDigits.ToString());
            writer.WriteAttributeString($"{prefix}.DecimalSeparator",source.DecimalSeparator);
            writer.WriteAttributeString($"{prefix}.GroupSeparator",source.GroupSeparator);
            writer.WriteAttributeString($"{prefix}.CurrencySymbol",source.CurrencySymbol);
            writer.WriteAttributeString($"{prefix}.PositivePattern",source.PositivePattern.ToString());
            writer.WriteAttributeString($"{prefix}.NegativePattern",source.NegativePattern.ToString());
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportDataBand,String,Object)
        void IFastReportSerializer.Serialize(FastReportDataBand source,String prefix,Object other) {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source,prefix,(descriptor)=> !String.Equals(descriptor.Name,"Sorts"));
                Serialize(source.Children,prefix);
                if (source.Sorts.Count > 0) {
                    using (writer.ElementGroup("Sort")) {
                        Serialize(source.Sorts,prefix);
                        }
                    }
                }
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
        #region M:IFastReportSerializer.Serialize(FastReportFormatBase,String,Object)
        void IFastReportSerializer.Serialize(FastReportFormatBase source,String prefix,Object other) {
            writer.WriteAttribute(prefix,FastReportFormatConverter.Instance.ConvertToInvariantString(source));
            SerializeAttributes(source,prefix);
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportGridControl,String,Object)
        void IFastReportSerializer.Serialize(FastReportGridControl source,String prefix,Object other) {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source,prefix,(descriptor)=> descriptor.Name != "Columns");
                if ((source.Columns != null) && (source.Columns.Count > 0)) {
                    using (writer.ElementGroup("Columns")) {
                        Serialize(source.Columns,prefix);
                        }
                    }
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportHyperlink,String,Object)
        void IFastReportSerializer.Serialize(FastReportHyperlink source,String prefix,Object other) {
            SerializeAttributes(source,prefix);
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportMatrixObject,String,Object)
        void IFastReportSerializer.Serialize(FastReportMatrixObject source,String prefix,Object other) {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source,prefix,(descriptor)=>
                    (descriptor.Name != "Columns") &&
                    (descriptor.Name != "Rows")    &&
                    (descriptor.Name != "Cells"));
                if (source.Columns.Any()) {
                    using (writer.ElementGroup("MatrixColumns")) {
                        Serialize(source.Columns,prefix);
                        }
                    }
                using (writer.ElementGroup("MatrixRows")) {
                    Serialize(source.Rows,prefix);
                    }
                if (source.Cells.Any()) {
                    using (writer.ElementGroup("MatrixCells")) {
                        Serialize(source.Cells,prefix);
                        }
                    }
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportNumberFormat,String,Object)
        void IFastReportSerializer.Serialize(FastReportNumberFormat source,String prefix,Object other) {
            writer.WriteAttributeString(prefix,FastReportFormatConverter.Instance.ConvertToInvariantString(source));
            if (source.UseLocale) {
                writer.WriteAttributeString($"{prefix}.UseLocale","true");
                return;
                }
            writer.WriteAttributeString($"{prefix}.UseLocale","false");
            writer.WriteAttributeString($"{prefix}.DecimalDigits",source.DecimalDigits.ToString());
            writer.WriteAttributeString($"{prefix}.DecimalSeparator",source.DecimalSeparator);
            writer.WriteAttributeString($"{prefix}.GroupSeparator",source.GroupSeparator);
            writer.WriteAttributeString($"{prefix}.NegativePattern",source.NegativePattern.ToString());
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportPageColumns,String,Object)
        void IFastReportSerializer.Serialize(FastReportPageColumns source,String prefix,Object other) {
            SerializeAttributes(source,prefix);
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportPercentFormat,String,Object)
        void IFastReportSerializer.Serialize(FastReportPercentFormat source,String prefix,Object other) {
            writer.WriteAttributeString(prefix,FastReportFormatConverter.Instance.ConvertToInvariantString(source));
            if (source.UseLocale) {
                writer.WriteAttributeString($"{prefix}.UseLocale","true");
                return;
                }
            writer.WriteAttributeString($"{prefix}.UseLocale","false");
            writer.WriteAttributeString($"{prefix}.DecimalDigits",source.DecimalDigits.ToString());
            writer.WriteAttributeString($"{prefix}.DecimalSeparator",source.DecimalSeparator);
            writer.WriteAttributeString($"{prefix}.GroupSeparator",source.GroupSeparator);
            writer.WriteAttributeString($"{prefix}.PercentSymbol",source.PercentSymbol);
            writer.WriteAttributeString($"{prefix}.PositivePattern",source.PositivePattern.ToString());
            writer.WriteAttributeString($"{prefix}.NegativePattern",source.NegativePattern.ToString());
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportPickControl,String,Object)
        void IFastReportSerializer.Serialize(FastReportPickControl source,String prefix,Object other) {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source,prefix);
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportPictureObject,String,Object)
        void IFastReportSerializer.Serialize(FastReportPictureObject source,String prefix,Object other)
            {
            Serialize(source,prefix,other);
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportPrintSettings,String,Object)
        void IFastReportSerializer.Serialize(FastReportPrintSettings source,String prefix,Object other) {
            SerializeAttributes(source,prefix);
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportRichObject,String,Object)
        void IFastReportSerializer.Serialize(FastReportRichObject source,String prefix,Object other) {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                var formats = source.Formats;
                SerializeAttributes(source,prefix,(descriptor)=> {
                    if (descriptor.Name == nameof(source.Formats)) { return false; }
                    if (descriptor.Name == nameof(source.Format)) {
                        return (formats != null) && (formats.Count == 1);
                        }
                    return true;
                    });
                if ((formats != null) && (formats.Count > 1)) {
                    using (writer.ElementGroup("Formats")) {
                        foreach(var o in formats) {
                            SerializeElement(o,prefix,null);
                            }
                        }
                    }
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportSolidFill,String,Object)
        void IFastReportSerializer.Serialize(FastReportSolidFill source,String prefix,Object other) {
            if (other != null) {
                if (other.GetType() != source.GetType()) {
                    writer.WriteAttribute(prefix,FastReportFillConverter.Instance.ConvertToInvariantString(source));
                    }
                }
            else
                {
                writer.WriteAttribute(prefix,FastReportFillConverter.Instance.ConvertToInvariantString(source));
                }
            writer.WriteAttributeString($"{prefix}.Color",source.color?.ToString());
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportTableDataSource,String,Object)
        void IFastReportSerializer.Serialize(FastReportTableDataSource source,String prefix,Object other)
            {
            Serialize(source,prefix,other);
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportTextObject,String,Object)
        void IFastReportSerializer.Serialize(FastReportTextObject source,String prefix,Object other) {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                var formats = source.Formats;
                SerializeAttributes(source,prefix,(descriptor)=> {
                    if (descriptor.Name == nameof(source.Highlights)) { return false; }
                    if (descriptor.Name == nameof(source.Formats))    { return false; }
                    if (descriptor.Name == nameof(source.Format)) {
                        return (formats != null) && (formats.Count == 1);
                        }
                    return true;
                    });
                if ((formats != null) && (formats.Count > 1)) {
                    using (writer.ElementGroup("Formats")) {
                        foreach(var o in formats) {
                            SerializeElement(o,prefix,null);
                            }
                        }
                    }
                if ((source.Highlights != null) && source.Highlights.Any()) {
                    using (writer.ElementGroup("Highlight")) {
                        Serialize(source.Highlights,prefix);
                        }
                    }
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportWatermark,String,Object)
        void IFastReportSerializer.Serialize(FastReportWatermark source,String prefix,Object other) {
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
                    serializer.Serialize(writer,source,descriptor);
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
                    writer.WriteAttributeString(String.IsNullOrWhiteSpace(prefix)
                        ? $"{name}"
                        : $"{prefix}.{name}",(String)value);
                    }
                }
            }
        #endregion
        #region M:SerializeAttributes<T>(T,String,Func<PropertyDescriptor,Boolean>)
        protected void SerializeAttributes<T>(T source,String prefix,Func<PropertyDescriptor,Boolean> predicate = null) {
            if (source == null) { throw new ArgumentNullException(nameof(source)); }
            foreach (var descriptor in TypeDescriptor.GetProperties(source)
                .Cast<PropertyDescriptor>()
                .Select(CreateDescriptor)
                .OrderBy(Order))
                {
                if ((predicate == null) || predicate(descriptor)) {
                    SerializeAttribute(source,prefix,descriptor);
                    }
                }
            }
        #endregion
        #region M:SerializeElement<T>(T,String,Object)
        protected virtual void SerializeElement<T>(T source,String prefix,Object other)
            where T: FastReportObject,IFastReportClassObjectLegacy
            {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source,prefix);
                Serialize(source.Children,prefix);
                }
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
        #region M:CreateDescriptor(PropertyDescriptor):PropertyDescriptor
        protected virtual PropertyDescriptor CreateDescriptor(PropertyDescriptor descriptor)
            {
            return new PropLink(descriptor);
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
        #region M:Dispose(Boolean)
        protected override void Dispose(Boolean disposing) {
            if (disposeWriter) {
                if (writer is IDisposable disposable) {
                    disposable.Dispose();
                    writer = null;
                    }
                }
            base.Dispose(disposing);
            }
        #endregion
        #region M:IsNullOrEmpty(String):Boolean
        protected static Boolean IsNullOrEmpty(String value) {
            return String.IsNullOrEmpty(value);
            }
        #endregion
        #region M:IsNullOrEmpty(ICollection):Boolean
        /// <summary>Determines whether the specified collection is <see langword="null"/> or empty.</summary>
        /// <param name="value">The <see cref="ICollection"/> instance to test.</param>
        /// <returns>
        /// <see langword="true"/> if <paramref name="value"/> is <see langword="null"/> or contains
        /// no elements (i.e. <see cref="ICollection.Count"/> equals zero); otherwise, <see langword="false"/>.
        /// </returns>
        protected static Boolean IsNullOrEmpty(ICollection value) {
            return (value == null) || (value.Count == 0);
            }
        #endregion
        #region M:IsNullOrEmpty<T>(ICollection):Boolean
        /// <summary>Determines whether the specified collection is <see langword="null"/> or empty.</summary>
        /// <param name="value">The <see cref="ICollection{T}"/> instance to test.</param>
        /// <returns>
        /// <see langword="true"/> if <paramref name="value"/> is <see langword="null"/> or contains
        /// no elements (i.e. <see cref="ICollection{T}.Count"/> equals zero); otherwise, <see langword="false"/>.
        /// </returns>
        protected static Boolean IsNullOrEmpty<T>(ICollection<T> value) {
            return (value == null) || (value.Count == 0);
            }
        #endregion

        protected ISqlXmlWriter writer;
        protected Stream stream;
        private readonly Boolean disposeWriter;
        }
    }
