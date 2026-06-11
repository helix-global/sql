using System;
using System.ComponentModel;
using System.Globalization;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public class SqlObjectConverter<T> : TypeConverter
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
