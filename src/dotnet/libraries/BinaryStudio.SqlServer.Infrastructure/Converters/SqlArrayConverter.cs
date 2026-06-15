using System;
using System.ComponentModel;
using System.Globalization;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlArrayConverter : ArrayConverter,ISqlArrayConverter
        {
        public static readonly SqlArrayConverter Default = new SqlArrayConverter();

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
            if (TryConvertFrom(value,out var r)) {
                return r;
                }
            return base.ConvertTo(context,culture,value,destinationType);
            }
        #endregion
        #region M:TryConvertFrom(Object,out Byte[]):Boolean
        public Boolean TryConvertFrom(Object value,out Byte[] result) {
            result = null;
            if ((value == null) || (value is DBNull)) { return true; }
            if (value is Byte[] A) { result = A; return true; }
            if (SqlBase64ArrayConverter.Default.TryConvertFrom(value, out result)) { return true; }
            if (SqlBase32ArrayConverter.Default.TryConvertFrom(value, out result)) { return true; }
            return false;
            }
        #endregion
        #region M:Equals(Byte[],Byte[]):Boolean
        public static Boolean Equals(Byte[] x,Byte[] y) {
            if (ReferenceEquals(x,y)) { return true; }
            if ((x == null) || (y == null) || (x.Length != y.Length)) { return false; }
            for (var i = 0; i < x.Length; i++) {
                if (x[i] != y[i]) { return false; }
                }
            return true;
            }
        #endregion
        }
    }
