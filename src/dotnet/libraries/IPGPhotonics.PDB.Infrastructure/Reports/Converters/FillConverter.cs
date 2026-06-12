using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal class FillConverter : TypeConverter
        {
        public static readonly FillConverter Instance = new FillConverter();

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
            if (destinationType == typeof(FillBase)) {
                if (value is String S) {
                    if (Types.TryGetValue(S,out var type)) {
                        return Activator.CreateInstance(type);
                        }
                    }
                }
            if (destinationType == typeof(String)) {
                if (value is FillBase B) {
                    foreach (var pair in Types) {
                        if (pair.Value == B.GetType()) {
                            return pair.Key;
                            }
                        }
                    }
                }
            return base.ConvertTo(context,culture,value,destinationType);
            }
        #endregion

        private static readonly IDictionary<String,Type> Types = new Dictionary<String,Type> {
            {"Solid",          typeof(FastReportSolidFill)          },
            {"LinearGradient", typeof(LinearGradientFill) },
            {"PathGradient",   typeof(FastReportPathGradientFill)   },
            {"Hatch",          typeof(HatchFill)          },
            {"Glass",          typeof(GlassFill)          }
            };
        }
    }