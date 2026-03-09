using System.Collections.Generic;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    internal interface ISqlScriptTableDefinition
        {
        IList<ISqlScriptConstraint> Constraints { get; }
        IList<ISqlScriptColumnDefinition> ColumnDefinitions { get; }
        }
    }