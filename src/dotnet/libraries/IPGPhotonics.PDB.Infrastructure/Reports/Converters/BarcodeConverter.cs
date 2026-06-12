using BinaryStudio.SqlServer.Infrastructure;
using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Globalization;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal class BarcodeConverter : TypeConverter
        {
        public static readonly BarcodeConverter Instance = new BarcodeConverter();
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
            if (destinationType == typeof(FastReportBarcodeBase)) {
                if (value is String S) {
                    if (Types.TryGetValue(S,out var type)) {
                        return Activator.CreateInstance(type);
                        }
                    }
                }
            if (destinationType == typeof(String)) {
                if (value is FastReportBarcodeBase B) {
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
                {"2/5 Interleaved", typeof(FastReportBarcode2of5Interleaved)},
                {"2/5 Industrial",  typeof(FastReportBarcode2of5Industrial) },
                {"2/5 Matrix",      typeof(FastReportBarcode2of5Matrix)     },
                {"Codabar",         typeof(FastReportBarcodeCodabar)        },
                {"Code128",         typeof(FastReportBarcode128)            },
                {"Code39",          typeof(FastReportBarcode39)             },
                {"Code39 Extended", typeof(FastReportBarcode39Extended)     },
                {"Code93",          typeof(FastReportBarcode93)             },
                {"Code93 Extended", typeof(FastReportBarcode93Extended)     },
                {"EAN8",            typeof(FastReportBarcodeEAN8)           },
                {"EAN13",           typeof(FastReportBarcodeEAN13)          },
                {"MSI",             typeof(FastReportBarcodeMSI)            },
                {"PostNet",         typeof(FastReportBarcodePostNet)        },
                {"UPC-A",           typeof(FastReportBarcodeUPC_A)          },
                {"UPC-E0",          typeof(FastReportBarcodeUPC_E0)         },
                {"UPC-E1",          typeof(FastReportBarcodeUPC_E1)         },
                {"Supplement 2",    typeof(FastReportBarcodeSupplement2)    },
                {"Supplement 5",    typeof(FastReportBarcodeSupplement5)    },
                {"PDF417",          typeof(FastReportBarcodePDF417)         },
                {"Datamatrix",      typeof(FastReportBarcodeDatamatrix)     },
                {"QR Code",         typeof(FastReportBarcodeQR)             }
                };
        }

    internal class BarcodeConverter<T> : TypeConverter
        where T : FastReportBarcodeBase
        {
        #region M:ConvertFrom(ITypeDescriptorContext,CultureInfo,Object):Object
        /// <summary>Converts the given object to the converter's native type.</summary>
        /// <param name="context">A <see cref="T:System.ComponentModel.TypeDescriptor"/> that provides a format context. You can use this object to get additional information about the environment from which this converter is being invoked.</param>
        /// <param name="culture">A <see cref="T:System.Globalization.CultureInfo"/> that specifies the culture to represent the color.</param>
        /// <param name="value">The object to convert.</param>
        /// <returns>An <see cref="T:System.Object"/> representing the converted value.</returns>
        /// <exception cref="T:System.ArgumentException">The conversion cannot be performed.</exception>
        public override Object ConvertFrom(ITypeDescriptorContext context,CultureInfo culture,Object value) {
            if ((value == null) || (value is String)) {
                var options = new SqlStringOptionCollection(value as String);
                var target = Activator.CreateInstance(typeof(T));
                foreach (PropertyDescriptor pi in TypeDescriptor.GetProperties(target)) {
                    if (options.TryGetValue(pi.Name,out var option)) {
                        var converter = pi.Converter??TypeDescriptor.GetConverter(pi.PropertyType);
                        if (converter != null) {
                            try
                                {
                                pi.SetValue(target,converter.ConvertTo(context,culture,option,pi.PropertyType));
                                }
                            catch (Exception)
                                {
                                throw;
                                }
                            }
                        }
                    }
                return target;
                }
            return base.ConvertFrom(context,culture,value);
            }
        #endregion
        }
    }