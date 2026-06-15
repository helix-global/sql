using System;
using System.ComponentModel;
using System.Globalization;
using BinaryStudio.SqlServer.Infrastructure;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    using DColor = System.Drawing.Color;

    internal class FastReportColorConverter : SqlColorConverter
        {
        public static readonly FastReportColorConverter Instance = new FastReportColorConverter();

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
                if (value is DColor DC) {
                    if (!DC.IsKnownColor) {
                        return (DC.A == 255)
                            ? $"{DC.R}, {DC.G}, {DC.B}"
                            : $"{DC.A}, {DC.R}, {DC.G}, {DC.B}";
                        }
                    }
                }
            if (destinationType == typeof(DColor)) {
                if (value is String s) {
                    return new DColorConverter().ConvertTo(null,culture,value,destinationType);
                    }
                }
            return base.ConvertTo(context,culture,value,destinationType);
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
            if (value is String s) {
                return new DColorConverter().ConvertFrom(value);
                }
            return base.ConvertFrom(context,culture,value);
            }
        #endregion
        }
    }
