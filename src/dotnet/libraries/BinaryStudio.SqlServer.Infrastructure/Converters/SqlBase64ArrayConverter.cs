using System;
using System.ComponentModel;
using System.Globalization;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SqlBase64ArrayConverter : TypeConverter,ISqlArrayConverter
        {
        public static readonly SqlBase64ArrayConverter Default = new SqlBase64ArrayConverter();

        #region M:CanConvertFrom(ITypeDescriptorContext,Type):Boolean
        /// <summary>Returns whether this converter can convert an object of the given type to the type of this converter, using the specified context.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <param name="sourceType">A <see cref="T:System.Type" /> that represents the type you want to convert from.</param>
        /// <returns><see langword="true" />if this converter can perform the conversion; otherwise, <see langword="false"/>.</returns>
        public override Boolean CanConvertFrom(ITypeDescriptorContext context,Type sourceType) {
            if ((sourceType == typeof(String)) ||
                (sourceType == typeof(Byte[])))
                {
                return true;
                }
            return base.CanConvertFrom(context, sourceType);
            }
        #endregion
        #region M:ConvertFrom(ITypeDescriptorContext,CultureInfo,Object):Object
        /// <summary>Converts the given object to the type of this converter, using the specified context and culture information.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <param name="culture">The <see cref="T:System.Globalization.CultureInfo"/> to use as the current culture.</param>
        /// <param name="value">The <see cref="T:System.Object"/> to convert.</param>
        /// <returns>An <see cref="T:System.Object"/> that represents the converted value.</returns>
        /// <exception cref="T:System.NotSupportedException">The conversion cannot be performed.</exception>
        public override Object ConvertFrom(ITypeDescriptorContext context,CultureInfo culture,Object value) {
            if ((value == null) || (value is DBNull)) { return null; }
            if (value is Byte[]  A)  { return A; }
            return ConvertFrom((value.ToString()).Trim());
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
            if (destinationType == typeof(Byte[])) {
                var r = ConvertFrom(value);
                return r;
                }
            if (destinationType == typeof(String)) {
                var r = (Byte[])ConvertFrom(value);
                return (r != null)
                    ? Convert.ToBase64String(r)
                    : String.Empty;
                }
            return base.ConvertTo(context,culture,value,destinationType);
            }
        #endregion
        #region M:ConvertFrom(String):Byte[]
        private Byte[] ConvertFrom(String value) {
            if (String.IsNullOrEmpty(value)) { return null; }
            return Convert.FromBase64String(value);
            }
        #endregion
        #region M:TryConvertFrom(Object,out Byte[]):Boolean
        public Boolean TryConvertFrom(Object value,out Byte[] result) {
            result = null;
            if ((value == null) || (value is DBNull)) { return false; }
            if (value is Byte[] A) { result = A; return true; }
            var s = value.ToString().Trim();
            if (String.IsNullOrEmpty(s)) { return false; }
            try
                {
                result = Convert.FromBase64String(s);
                return true;
                }
            catch (FormatException)
                {
                return false;
                }
            }
        #endregion
        }
    }
