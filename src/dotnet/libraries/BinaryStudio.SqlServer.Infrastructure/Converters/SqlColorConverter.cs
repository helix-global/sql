using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Diagnostics.CodeAnalysis;
using System.Globalization;
using System.Linq;
using System.Reflection;
using System.Text.RegularExpressions;
using System.Windows.Media;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using DColor = System.Drawing.Color;
    using MColor = System.Windows.Media.Color;

    public class SqlColorConverter : TypeConverter
        {
        #region M:CanConvertTo(ITypeDescriptorContext,Type):Boolean
        /// <summary>Returns whether this converter can convert the object to the specified type, using the specified context.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <param name="destinationType">A <see cref="T:System.Type"/> that represents the type you want to convert to.</param>
        /// <returns><see langword="true"/> if this converter can perform the conversion; otherwise, <see langword="false"/>.</returns>
        public override Boolean CanConvertTo(ITypeDescriptorContext context,Type destinationType) {
            return (destinationType == typeof(String))
                || (destinationType == typeof(DColor))
                || (destinationType == typeof(MColor));
            }
        #endregion
        #region M:CanConvertFrom(ITypeDescriptorContext,Type):Boolean
        /// <summary>Determines if this converter can convert an object in the given source type to the native type of the converter.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context. You can use this object to get additional information about the environment from which this converter is being invoked.</param>
        /// <param name="sourceType">The type from which you want to convert.</param>
        /// <returns><see langword="true"/> if this object can perform the conversion; otherwise, <see langword="false"/>.</returns>
        public override Boolean CanConvertFrom(ITypeDescriptorContext context,Type sourceType) {
            if (sourceType == typeof(String))
                {
                return true;
                }
            return base.CanConvertFrom(context,sourceType);
            }
        #endregion
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
            return converters.TryGetValue(destinationType,out var converter)
                ? converter.ConvertTo(context,culture,value,destinationType)
                : base.ConvertTo(context,culture,value,destinationType);
            }
        #endregion
        #region M:ConvertFrom(ITypeDescriptorContext,CultureInfo,Object):Object
        /// <summary>Converts the given object to the converter's native type.</summary>
        /// <param name="context">A <see cref="T:System.ComponentModel.TypeDescriptor"/> that provides a format context. You can use this object to get additional information about the environment from which this converter is being invoked.</param>
        /// <param name="culture">A <see cref="T:System.Globalization.CultureInfo"/> that specifies the culture to represent the color.</param>
        /// <param name="value">The object to convert.</param>
        /// <returns>An <see cref="T:System.Object"/> representing the converted value.</returns>
        /// <exception cref="T:System.ArgumentException">The conversion cannot be performed.</exception>
        public override Object ConvertFrom(ITypeDescriptorContext context,CultureInfo culture,Object value)
            {
            throw new NotImplementedException();
            }
        #endregion
        #region M:ConvertToString(Color?):String
        public static String ConvertToString(MColor? value) {
            if (value != null) {

                }
            return null;
            }
        #endregion

        private class SColorConverter : TypeConverter {
            #region M:CanConvertTo(ITypeDescriptorContext,Type):Boolean
            /// <summary>Returns whether this converter can convert the object to the specified type, using the specified context.</summary>
            /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
            /// <param name="destinationType">A <see cref="T:System.Type"/> that represents the type you want to convert to.</param>
            /// <returns><see langword="true"/> if this converter can perform the conversion; otherwise, <see langword="false"/>.</returns>
            public override Boolean CanConvertTo(ITypeDescriptorContext context,Type destinationType) {
                return (destinationType == typeof(String));
                }
            #endregion
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
                //if (destinationType != typeof(String)) { throw new NotSupportedException($@"Cannot convert to ""{destinationType.AssemblyQualifiedName}"""); }
                //if (value is DColor DC) {
                //    var state = (Int16)ColorStateField.GetValue(DC);
                //    if ((state & ColorStateNameValid) != 0)       { return DC.Name; }
                //    if ((state & ColorStateKnownColorValid) != 0) { return DC.Name; }
                //    return $@"#{DC.A:x2}{DC.R:x2}{DC.G:x2}{DC.B:x2}";
                //    }
                if (value is MColor MC) { return converterM.ConvertTo(context,culture,value,destinationType); }
                if (value is DColor DC) { return converterD.ConvertTo(context,culture,value,destinationType); }
                return base.ConvertTo(context,culture,value,destinationType);
                }
            #endregion
            }

        private class DColorConverter : TypeConverter {
            #region M:CanConvertTo(ITypeDescriptorContext,Type):Boolean
            /// <summary>Returns whether this converter can convert the object to the specified type, using the specified context.</summary>
            /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
            /// <param name="destinationType">A <see cref="T:System.Type"/> that represents the type you want to convert to.</param>
            /// <returns><see langword="true"/> if this converter can perform the conversion; otherwise, <see langword="false"/>.</returns>
            public override Boolean CanConvertTo(ITypeDescriptorContext context,Type destinationType) {
                return
                    (destinationType == typeof(DColor)) ||
                    (destinationType == typeof(String));
                }
            #endregion
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
                if (destinationType != typeof(DColor)) { throw new NotSupportedException($@"Cannot convert to ""{destinationType.AssemblyQualifiedName}"""); }
                if (value is String S) {
                    if (Enum.TryParse<System.Drawing.KnownColor>(S,out var r)) { return DColor.FromKnownColor(r); }
                    if (S.StartsWith("#")) {
                        if (S.Length == 7) {
                            var A = Byte.Parse("ff",NumberStyles.HexNumber);
                            var R = Byte.Parse(S.Substring(1,2),NumberStyles.HexNumber);
                            var G = Byte.Parse(S.Substring(3,2),NumberStyles.HexNumber);
                            var B = Byte.Parse(S.Substring(5,2),NumberStyles.HexNumber);
                            return DColor.FromArgb(A,R,G,B);
                            }
                        if (S.Length == 9) {
                            var A = Byte.Parse(S.Substring(1,2),NumberStyles.HexNumber);
                            var R = Byte.Parse(S.Substring(3,2),NumberStyles.HexNumber);
                            var G = Byte.Parse(S.Substring(5,2),NumberStyles.HexNumber);
                            var B = Byte.Parse(S.Substring(7,2),NumberStyles.HexNumber);
                            return DColor.FromArgb(A,R,G,B);
                            }
                        }
                    var c = culture.TextInfo.ListSeparator[0];
                    if (S.IndexOf(c) != -1) {
                        var values = S.Split(c).Select(i=>(Int32)SqlInt32Converter.DoesNotAllowNull.ConvertFromString(i)).ToArray();
                        switch (values.Length) {
                            case 1: return DColor.FromArgb(values[0]);
                            case 3: return DColor.FromArgb(values[0],values[1],values[2]);
                            case 4: return DColor.FromArgb(values[0],values[1],values[2],values[3]);
                            }
                        }
                    if (String.IsNullOrWhiteSpace(S)) { return DColor.Black; }
                    }
                return base.ConvertTo(context,culture,value,destinationType);
                }
            #endregion
            }

        private class MColorConverter : TypeConverter {
            #region M:CanConvertTo(ITypeDescriptorContext,Type):Boolean
            /// <summary>Returns whether this converter can convert the object to the specified type, using the specified context.</summary>
            /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
            /// <param name="destinationType">A <see cref="T:System.Type"/> that represents the type you want to convert to.</param>
            /// <returns><see langword="true"/> if this converter can perform the conversion; otherwise, <see langword="false"/>.</returns>
            public override Boolean CanConvertTo(ITypeDescriptorContext context,Type destinationType) {
                return
                    (destinationType == typeof(MColor)) ||
                    (destinationType == typeof(String));
                }
            #endregion
            #region M:ConvertTo(ITypeDescriptorContext,CultureInfo,Object,Type):Object
            /// <summary>Converts the given value object to the specified type, using the specified context and culture information.</summary>
            /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
            /// <param name="culture">A <see cref="T:System.Globalization.CultureInfo"/>. If <see langword="null"/> is passed, the current culture is assumed.</param>
            /// <param name="value">The <see cref="T:System.Object"/> to convert.</param>
            /// <param name="destinationType">The <see cref="T:System.Type"/> to convert the <paramref name="value"/> parameter to.</param>
            /// <returns>An <see cref="T:System.Object"/> that represents the converted value.</returns>
            /// <exception cref="T:System.ArgumentNullException">The <paramref name="destinationType"/> parameter is <see langword="null"/>.</exception>
            /// <exception cref="T:System.NotSupportedException">The conversion cannot be performed.</exception>
            [SuppressMessage("ReSharper", "PossibleInvalidOperationException")]
            public override Object ConvertTo(ITypeDescriptorContext context,CultureInfo culture,Object value,Type destinationType) {
                if (destinationType == null) { throw new ArgumentNullException(nameof(destinationType)); }
                if (destinationType == typeof(MColor)) {
                    if (value is DBNull) { return null; }
                    if (value is String S) {
                        if (Int32.TryParse(S,out var SI4)) {
                            var UI4 = unchecked((UInt32)SI4);
                            return FromUInt32(UI4);
                            }
                        return ColorConverter.ConvertFromString(S);
                        }
                    }
                if (destinationType == typeof(String)) {
                    if (value is MColor color) {
                        var UI4 = (UInt32)SqlUInt32Converter.ConvertFromObject(color);
                        if (ColorNames.TryGetValue(UI4,out var colorname)) {
                            return colorname;
                            }
                        return value.ToString();
                        }
                    }
                return base.ConvertTo(context,culture,value,destinationType);
                }
            #endregion
            #region M:FromUInt32(UInt32):Color
            private static MColor FromUInt32(UInt32 value) {
                var a = (Byte)((value & 0xff000000u) >> 24);
                var r = (Byte)((value & 0xff0000) >> 16);
                var g = (Byte)((value & 0xff00) >> 8);
                var b = (Byte)(value & 0xff);
                return MColor.FromArgb(a,r,g,b);
                }
            #endregion

            private static readonly IDictionary<UInt32,String> ColorNames = new Dictionary<UInt32,String>();
            static MColorConverter()
                {
                var values = Enum.GetValues(typeof(MColor).Assembly.GetType("System.Windows.Media.KnownColor"));
                foreach (var value in values) {
                    if ((UInt32)value != 1) {
                        ColorNames[(UInt32)value] = value.ToString();
                        }
                    }
                }
            }

        private const Int16 ColorStateNameValid       = 8;
        private const Int16 ColorStateKnownColorValid = 1;
        private static readonly FieldInfo ColorStateField = typeof(DColor).GetField("state",BindingFlags.NonPublic | BindingFlags.Instance);
        private static readonly MColorConverter converterM = new MColorConverter();
        private static readonly DColorConverter converterD = new DColorConverter();
        private static readonly SColorConverter converterS = new SColorConverter();
        private static readonly IDictionary<Type,TypeConverter> converters = new Dictionary<Type,TypeConverter>();

        static SqlColorConverter()
            {
            converters[typeof(String)] = converterS;
            converters[typeof(DColor)] = converterD;
            converters[typeof(MColor)] = converterM;
            }
        }
    }