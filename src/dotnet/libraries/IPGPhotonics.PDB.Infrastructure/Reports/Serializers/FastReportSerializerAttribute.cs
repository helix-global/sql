using System;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    [AttributeUsage(AttributeTargets.Property,AllowMultiple = false,Inherited = false)]
    internal class FastReportSerializerAttribute : Attribute
        {
        public Type SerializerType { get; }
        public FastReportSerializerAttribute(Type serializerType) {
            if (serializerType == null) throw new ArgumentNullException(nameof(serializerType));
            if (!typeof(IFastReportSerializer).IsAssignableFrom(serializerType)) throw new ArgumentException($"Type {serializerType.FullName} does not implement {typeof(IFastReportSerializer).FullName}",nameof(serializerType));
            SerializerType = serializerType;
            }
        }
    }
