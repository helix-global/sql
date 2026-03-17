using System;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    public interface ISqlFillFactorIndexOption : ISqlIndexOption
        {
        Int32 FillFactor { get; }
        }
    }