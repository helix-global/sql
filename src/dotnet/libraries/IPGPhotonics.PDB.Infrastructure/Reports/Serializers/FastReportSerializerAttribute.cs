using System;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [AttributeUsage(AttributeTargets.Property,AllowMultiple = false,Inherited = false)]
    internal class FastReportSerializerAttribute : Attribute
        {
        public Type SerializerType { get; }
        public FastReportSerializerAttribute(Type serializerType) {
            if (serializerType == null) throw new ArgumentNullException(nameof(serializerType));
            if (!typeof(IFastReportCustomSerializer).IsAssignableFrom(serializerType)) throw new ArgumentException($"Type {serializerType.FullName} does not implement {typeof(IFastReportCustomSerializer).FullName}",nameof(serializerType));
            SerializerType = serializerType;
            }
        }
    }
