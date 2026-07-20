using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Text.RegularExpressions;
using System.Windows;
using System.Xml.Linq;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using DColor=System.Drawing.Color;
    internal class FastReportSerializerEXT : FastReportSerializerSTD,IFastReportSerializer
        {
        #region ctor{ISqlXmlWriter}
        public FastReportSerializerEXT(ISqlXmlWriter writer)
            : base(writer)
            {
            }
        #endregion

        #region M:Serialize(FastReport)
        public override void Serialize(FastReport source)
            {
            source.Serialize(this,null,null);
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReport,String,Object)
        void IFastReportSerializer.Serialize(FastReport source,String prefix,Object other) {
            var ClassName = "Report";
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source, prefix, (descriptor) => {
                    return (descriptor.Name != "ReferencedAssemblies") &&
                           (descriptor.Name != "ReportInfo");
                    });
                using (writer.ElementGroup($"Info")) {
                    source.ReportInfo.Serialize(this,null,null);
                    }
                if (!IsNullOrEmpty(source.ReferencedAssemblies)) {
                    writer.WriteCData($"ReferencedAssemblies",source.ReferencedAssemblies);
                    }
                if (!String.IsNullOrWhiteSpace(source.Script)) {
                    writer.WriteCData($"Script",source.Script);
                    }
                WriteElementGroup("Styles",prefix,source.Styles);
                WriteElementGroup("DataSources",prefix,source.DataSources);
                WriteElementGroup("Relations",prefix,source.Relations);
                WriteElementGroup("Parameters",prefix,source.Parameters);
                WriteElementGroup("Totals",prefix,source.Totals);
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportBarcodeBase,String,Object)
        void IFastReportSerializer.Serialize(FastReportBarcodeBase source,String prefix,Object other) {
            var ClassName = source.GetType().Name.Substring(10);
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportBarcodeObject,String,Object)
        void IFastReportSerializer.Serialize(FastReportBarcodeObject source,String prefix,Object other) {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source,prefix,(descriptor)=>
                    !String.Equals(descriptor.Name,"Barcode"));
                if (source.Barcode != null) {
                    using (writer.ElementGroup("Barcode")) {
                        source.Barcode.Serialize(this,prefix,null);
                        }
                    }
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportButtonBaseControl,String,Object)
        void IFastReportSerializer.Serialize(FastReportButtonBaseControl source,String prefix,Object other) {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source,prefix,(descriptor)=>
                    !String.Equals(descriptor.Name,nameof(FastReportButtonBaseControl.Image)));
                if (source.Image != null) {
                    writer.WriteBase64($"{ClassName}.Image",source.Image);
                    }
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportChartObject,String,Object)
        void IFastReportSerializer.Serialize(FastReportChartObject source,String prefix,Object other) {
            var ClassName = "ChartObject";
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source,prefix,(descriptor)=>
                    !String.Equals(descriptor.Name,"Chart"));
                if (source.Chart != null) {
                    using (writer.ElementGroup($"{ClassName}.Chart")) {
                        var content = XDocument.Load(new MemoryStream(source.Chart));
                        writer.WriteNode(content.CreateReader(), (ns) => {
                            if (!String.IsNullOrEmpty(ns)) { return ns; }
                            return "urn:schemas.microsoft.com:charting";
                            });
                        }
                    }
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportCurrencyFormat,String,Object)
        void IFastReportSerializer.Serialize(FastReportCurrencyFormat source,String prefix,Object other) {
            if (source.UseLocale) {
                writer.WriteAttributeString(prefix,FastReportFormatConverter.Instance.ConvertToInvariantString(source));
                writer.WriteAttributeString($"{prefix}.UseLocale","true");
                return;
                }
            var ClassName = "CurrencyFormat";
            using (writer.ElementGroup(ClassName)) {
                writer.WriteAttributeString($"UseLocale","false");
                writer.WriteAttributeString($"DecimalDigits",source.DecimalDigits.ToString());
                writer.ScheduleNewLineForNextAttribute().WriteAttributeString($"DecimalSeparator",source.DecimalSeparator);
                writer.WriteAttributeString($"GroupSeparator",source.GroupSeparator);
                writer.ScheduleNewLineForNextAttribute().WriteAttributeString($"CurrencySymbol",source.CurrencySymbol);
                writer.WriteAttributeString($"PositivePattern",source.PositivePattern.ToString());
                writer.ScheduleNewLineForNextAttribute().WriteAttributeString($"NegativePattern",source.NegativePattern.ToString());
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportDataConnection,String,Object)
        void IFastReportSerializer.Serialize(FastReportDataConnection source,String prefix,Object other) {
            var ClassName = "DataConnection";
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source,prefix);
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportInfo,String,Object)
        void IFastReportSerializer.Serialize(FastReportInfo source,String prefix,Object other) {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                var i = 1;
                SerializeAttributes(source, prefix,
                    (descriptor) => {
                        return descriptor.Name != "Name";
                        },
                    (descriptor) => {
                        i++;
                        if (i%3 == 0)
                            {
                            writer.ScheduleNewLineForNextAttribute();
                            }
                        else
                            {
                            writer.StopScheduleNewLineForNextAttribute();
                            }
                        });
                writer.WriteCData(source.Name);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportNumberFormat,String,Object)
        void IFastReportSerializer.Serialize(FastReportNumberFormat source,String prefix,Object other) {
            if (source.UseLocale) {
                writer.WriteAttributeString(prefix,FastReportFormatConverter.Instance.ConvertToInvariantString(source));
                writer.WriteAttributeString($"{prefix}.UseLocale","true");
                return;
                }
            var ClassName = "NumberFormat";
            using (writer.ElementGroup(ClassName)) {
                writer.WriteAttributeString($"UseLocale","false");
                writer.WriteAttributeString($"DecimalDigits",source.DecimalDigits.ToString());
                writer.ScheduleNewLineForNextAttribute().WriteAttributeString($"DecimalSeparator",source.DecimalSeparator);
                writer.WriteAttributeString($"GroupSeparator",source.GroupSeparator);
                writer.ScheduleNewLineForNextAttribute().WriteAttributeString($"NegativePattern",source.NegativePattern.ToString());
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportParameter,String,Object)
        void IFastReportSerializer.Serialize(FastReportParameter source,String prefix,Object other) {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                foreach (var descriptor in TypeDescriptor.GetProperties(source)
                    .Cast<PropertyDescriptor>()
                    .Select(CreateDescriptor)
                    .OrderBy(Order))
                    {
                    switch (descriptor.Name) {
                        case "DataType":
                            if (!String.IsNullOrWhiteSpace(source.DataType)) {
                                var r = Regex.Replace(source.DataType,@"A2Core, Version=\d+[.]\d+[.]\d+[.]\d+, Culture=neutral, PublicKeyToken=null",$"CoreFR, Culture=neutral");
                                writer.WriteAttributeString(nameof(source.DataType),r);
                                }
                            break;
                        default:
                            SerializeAttribute(source,prefix,descriptor);
                            break;
                        }
                    }
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportPercentFormat,String,Object)
        void IFastReportSerializer.Serialize(FastReportPercentFormat source,String prefix,Object other) {
            if (source.UseLocale) {
                writer.WriteAttributeString(prefix,FastReportFormatConverter.Instance.ConvertToInvariantString(source));
                writer.WriteAttributeString($"{prefix}.UseLocale","true");
                return;
                }
            var ClassName = "PercentFormat";
            using (writer.ElementGroup(ClassName)) {
                writer.WriteAttributeString($"UseLocale","false");
                writer.WriteAttributeString($"DecimalDigits",source.DecimalDigits.ToString());
                writer.ScheduleNewLineForNextAttribute().WriteAttributeString($"DecimalSeparator",source.DecimalSeparator);
                writer.WriteAttributeString($"GroupSeparator",source.GroupSeparator);
                writer.ScheduleNewLineForNextAttribute().WriteAttributeString($"PercentSymbol",source.PercentSymbol);
                writer.WriteAttributeString($"PositivePattern",source.PositivePattern.ToString());
                writer.ScheduleNewLineForNextAttribute().WriteAttributeString($"NegativePattern",source.NegativePattern.ToString());
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportPictureObject,String,Object)
        void IFastReportSerializer.Serialize(FastReportPictureObject source,String prefix,Object other) {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source,prefix,(descriptor)=>
                    !String.Equals(descriptor.Name,"Image"));
                if (source.Image != null) {
                    writer.WriteBase64($"{ClassName}.Image",source.Image);
                    }
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportRelation,String,Object)
        void IFastReportSerializer.Serialize(FastReportRelation source,String prefix,Object other) {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                if (source.ParentColumns.Count > 0) {
                    //Debugger.Break();
                    }
                SerializeAttributes(source,prefix);
                Serialize(source.Children,prefix);
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportTableDataSource,String,Object)
        void IFastReportSerializer.Serialize(FastReportTableDataSource source,String prefix,Object other) {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                SerializeAttributes(source,prefix,(descriptor)=>
                    !String.Equals(descriptor.Name,"SelectCommand"));
                if (!IsNullOrEmpty(source.Columns)) {
                    using (writer.ElementGroup("Columns")) {
                        Serialize(source.Columns,prefix);
                        }
                    }
                if (!IsNullOrEmpty(source.Parameters)) {
                    using (writer.ElementGroup("Parameters")) {
                        Serialize(source.Parameters,prefix);
                        }
                    }
                if (!String.IsNullOrWhiteSpace(source.SelectCommand)) {
                    writer.WriteCData(source.SelectCommand);
                    }
                }
            }
        #endregion
        #region M:IFastReportSerializer.Serialize(FastReportTextObject,String,Object)
        void IFastReportSerializer.Serialize(FastReportTextObject source,String prefix,Object other) {
            var ClassName = ((IFastReportClassObjectLegacy)source).ClassName;
            using (writer.ElementGroup(ClassName)) {
                var descriptors = TypeDescriptor.GetProperties(source)
                    .Cast<PropertyDescriptor>()
                    .ToDictionary(i => i.Name,i=>i);
                var formats = source.Formats;
                SerializeAttributes(source,prefix,descriptors.Select(i=>i.Value),(descriptor)=> {
                    if (descriptor.Name == nameof(source.Highlights)) { return false; }
                    if (descriptor.Name == nameof(source.Formats))    { return false; }
                    if (descriptor.Name == nameof(source.Format)) {
                        if ((formats != null) && (formats.Count == 1)) {
                            var format = formats[0];
                            if ((format != null) && format is IFastReportLocaleFormat locale) {
                                if (!locale.UseLocale) { return false; }
                                return true;
                                }
                            return true;
                            }
                        return false;
                        }
                    if (descriptor.Name == nameof(source.Text)) {
                        return String.IsNullOrWhiteSpace(source.Text) || !(source.Text.Contains('\n'));
                        }
                    return true;
                    });
                if (!String.IsNullOrWhiteSpace(source.Text) && source.Text.Contains('\n')) {
                    writer.WriteCData($"{ClassName}.Text",source.Text);
                    }
                if ((formats != null) && (formats.Count == 1)) {
                    var format = formats[0];
                    if ((format != null) && !IsDefaultValue(format,descriptors[nameof(source.Format)],out var _)) {
                        if (format is IFastReportLocaleFormat locale) {
                            if (!locale.UseLocale) {
                                using (writer.ElementGroup($"{ClassName}.Format")) {
                                    formats[0].Serialize(this,prefix,null);
                                    }
                                }
                            }
                        }
                    }
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
        #region M:CreateDescriptor(PropertyDescriptor):PropertyDescriptor
        protected override PropertyDescriptor CreateDescriptor(PropertyDescriptor descriptor)
            {
            return new PropDesc(base.CreateDescriptor(descriptor));
            }
        #endregion
        #region M:WriteElementGroup<T>(String,String,IList<T>)
        private void WriteElementGroup<T>(String name,String prefix,IList<T> values)
            where T:FastReportObject
            {
            if (IsNullOrEmpty(values)) { return; }
            using (writer.ElementGroup(name)) {
                Serialize(values,prefix);
                }
            }
        #endregion

        private class PropDesc : PropertyDescriptor
            {
            #region ctor{String,Attribute[]}
            public PropDesc(String name,Attribute[] attrs)
                : base(name,attrs)
                {
                }
            #endregion
            #region ctor{PropertyDescriptor}
            public PropDesc(PropertyDescriptor descr)
                : base(descr)
                {
                this.descr = descr;
                }
            #endregion
            #region ctor{MemberDescriptor,Attribute[]}
            public PropDesc(MemberDescriptor descr,Attribute[] attrs)
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
            #region P:Converter:TypeConverter
            public override TypeConverter Converter { get {
                var type = PropertyType;
                if (type == typeof(DateTime))  { return new DateTimeConverter();  }
                if (type == typeof(Thickness)) { return new ThicknessConverter(); }
                if (type == typeof(DColor))    { return new ColorConverter();     }
                return base.Converter;
                }}
            #endregion

            private readonly PropertyDescriptor descr;
            }

        private class ThicknessConverter : FastReportThicknessConverter
            {
            #region M:ConvertTo(ITypeDescriptorContext,CultureInfo,Object,Type):Object
            /// <summary>Converts the given value object to the specified type, using the specified context and culture information.</summary>
            /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
            /// <param name="culture">A <see cref="T:System.Globalization.CultureInfo"/>. If <see langword="null"/> is passed, the current culture is assumed.</param>
            /// <param name="value">The <see cref="T:System.Object"/> to convert.</param>
            /// <param name="destinationType">The <see cref="T:System.Type"/> to convert the <paramref name="value"/> parameter to.</param>
            /// <returns>An <see cref="T:System.Object"/> that represents the converted value.</returns>
            /// <exception cref="T:System.ArgumentNullException">The <paramref name="destinationType"/> parameter is <see langword="null"/>.</exception>
            /// <exception cref="T:System.NotSupportedException">The conversion cannot be performed.</exception>
            public override Object ConvertTo(ITypeDescriptorContext context,CultureInfo culture,Object value,Type destinationType) {
                if (destinationType == null) { throw new ArgumentNullException(nameof(destinationType)); }
                if (destinationType == typeof(String)) {
                    if (value is Thickness thickness) {
                        if ((thickness.Left == thickness.Right) &&
                            (thickness.Left == thickness.Top)   &&
                            (thickness.Left == thickness.Bottom))
                            {
                            return $"{thickness.Left}";
                            }
                        if ((thickness.Left == thickness.Right) &&
                            (thickness.Top  == thickness.Bottom))
                            {
                            return $"{thickness.Left}, {thickness.Top}";
                            }
                        }
                    }
                return base.ConvertTo(context,culture,value,destinationType);
                }
            #endregion
            }

        private class DateTimeConverter : SqlDateTimeConverter
            {
            #region M:ConvertTo(ITypeDescriptorContext,CultureInfo,Object,Type):Object
            /// <summary>Converts the given value object to the specified type, using the specified context and culture information.</summary>
            /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
            /// <param name="culture">A <see cref="T:System.Globalization.CultureInfo"/>. If <see langword="null"/> is passed, the current culture is assumed.</param>
            /// <param name="value">The <see cref="T:System.Object"/> to convert.</param>
            /// <param name="destinationType">The <see cref="T:System.Type"/> to convert the <paramref name="value"/> parameter to.</param>
            /// <returns>An <see cref="T:System.Object"/> that represents the converted value.</returns>
            /// <exception cref="T:System.ArgumentNullException">The <paramref name="destinationType"/> parameter is <see langword="null"/>.</exception>
            /// <exception cref="T:System.NotSupportedException">The conversion cannot be performed.</exception>
            public override Object ConvertTo(ITypeDescriptorContext context,CultureInfo culture,Object value,Type destinationType) {
                if (destinationType == null) { throw new ArgumentNullException(nameof(destinationType)); }
                if (destinationType == typeof(String)) {
                    var r = ConvertFromObject(value);
                    return r?.ToString("s");
                    }
                return base.ConvertTo(context,culture,value,destinationType);
                }
            #endregion
            }

        private class ColorConverter : FastReportColorConverter
            {
            #region M:ConvertTo(ITypeDescriptorContext,CultureInfo,Object,Type):Object
            /// <summary>Converts the given value object to the specified type, using the specified context and culture information.</summary>
            /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
            /// <param name="culture">A <see cref="T:System.Globalization.CultureInfo"/>. If <see langword="null"/> is passed, the current culture is assumed.</param>
            /// <param name="value">The <see cref="T:System.Object"/> to convert.</param>
            /// <param name="destinationType">The <see cref="T:System.Type"/> to convert the <paramref name="value"/> parameter to.</param>
            /// <returns>An <see cref="T:System.Object"/> that represents the converted value.</returns>
            /// <exception cref="T:System.ArgumentNullException">The <paramref name="destinationType"/> parameter is <see langword="null"/>.</exception>
            /// <exception cref="T:System.NotSupportedException">The conversion cannot be performed.</exception>
            public override Object ConvertTo(ITypeDescriptorContext context,CultureInfo culture,Object value,Type destinationType) {
                if (destinationType == null) { throw new ArgumentNullException(nameof(destinationType)); }
                if (destinationType == typeof(String)) {
                    if (value is DColor color) {
                        if (color.IsKnownColor) { return color.Name; }
                        var UI4 = (UInt32)SqlUInt32Converter.ConvertFromObject(color);
                        if (ColorNames.TryGetValue(UI4,out var colorname)) {
                            return colorname;
                            }
                        return $"#{UI4:x8}";
                        }
                    }
                return base.ConvertTo(context,culture,value,destinationType);
                }
            #endregion
            }
        }
    }
