using BinaryStudio.SqlServer.Infrastructure;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal class FastReportSingleConverter : SqlSingleConverter
        {
        public override Boolean AllowNull { get{ return false; }}

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
            if (destinationType == typeof(Single)) {
                if (value is String S) {
                    if (Decimal.TryParse(S,NumberStyles.Float|NumberStyles.AllowDecimalPoint,culture.NumberFormat,out var d)) {
                        return (Single)d;
                        }
                    }
                var r = ConvertFromObject(culture,value);
                return r;
                }
            if (destinationType == typeof(String)) {
                var r = ConvertFromObject(culture,value);
                if ((r == null) && (AllowNull == false)) {
                    throw new InvalidCastException();
                    }
                var d = (decimal)r.Value;
                var o = r.Value.ToString("g17");
                return o;
                }
            if (destinationType == typeof(Single?)) { return ConvertFromObject(culture,value); }
            return base.ConvertTo(context,culture,value,destinationType);
            }
        #endregion
        }
    }
