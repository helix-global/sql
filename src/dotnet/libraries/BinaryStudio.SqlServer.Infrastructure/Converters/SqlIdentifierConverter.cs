using System;
using System.ComponentModel;
using System.Globalization;
using SqlCodeDomIdentifier=Microsoft.SqlServer.Management.SqlParser.SqlCodeDom.SqlIdentifier;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal class SqlIdentifierConverter : TypeConverter
        {
        #region M:CanConvertFrom(ITypeDescriptorContext,Type):Boolean
        /// <summary>Returns whether this converter can convert an object of the given type to the type of this converter, using the specified context.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <param name="sourceType">A <see cref="T:System.Type" /> that represents the type you want to convert from.</param>
        /// <returns><see langword="true" />if this converter can perform the conversion; otherwise, <see langword="false"/>.</returns>
        public override Boolean CanConvertFrom(ITypeDescriptorContext context,Type sourceType) {
            if ((sourceType == typeof(String)) ||
                (sourceType == typeof(SqlIdentifier))||
                (sourceType == typeof(SqlCodeDomIdentifier)))
                {
                return true;
                }
            return base.CanConvertFrom(context,sourceType);
            }
        #endregion
        #region M:ConvertFrom(ITypeDescriptorContext,CultureInfo,Object):Object
        /// <summary>Converts the given object to the type of this converter, using the specified context and culture information.</summary>
        /// <param name="context">An <see cref="T:System.ComponentModel.ITypeDescriptorContext"/> that provides a format context.</param>
        /// <param name="culture">The <see cref="T:System.Globalization.CultureInfo"/> to use as the current culture.</param>
        /// <param name="value">The <see cref="T:System.Object"/> to convert.</param>
        /// <returns>An <see cref="T:System.Object"/> that represents the converted value.</returns>
        /// <exception cref="T:System.NotSupportedException">The conversion cannot be performed.</exception>
        public override Object ConvertFrom(ITypeDescriptorContext context, CultureInfo culture, Object value) {
            if ((value == null) || (value is DBNull)) { return null; }
            if (value is SqlIdentifier I) { return I; }
            if (value is SqlCodeDomIdentifier CodeDomIdentifier) { return new SqlIdentifier(CodeDomIdentifier.Value); }
            var S = (value.ToString()).Trim();
            if (String.IsNullOrEmpty(S)) { return null; }
            return new SqlIdentifier(S);
            }
        #endregion
        }
    }
