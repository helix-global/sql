using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlArrayConverter : ArrayConverter
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
        }
    }
