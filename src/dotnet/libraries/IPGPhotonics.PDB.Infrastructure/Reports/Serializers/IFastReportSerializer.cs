using System;

namespace IPGPhotonics.PDB.Infrastructure.Reports
    {
    internal interface IFastReportSerializer
        {
        void Serialize<T>(T source,String prefix,Object other) where T: FastReportObject;
        void Serialize(FastReportInfo source,String prefix,Object other);
        void Serialize(FastReport source,String prefix,Object other);
        void Serialize(FastReportFormatBase source,String prefix,Object other);
        void Serialize(FastReportFillBase source,String prefix,Object other);
        void Serialize(FastReportBorder source,String prefix,Object other);
        void Serialize(FastReportBorderLine source,String prefix,Object other);
        }
    }
