using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlAllowRowLocksIndexOption))]
    internal sealed class SqlScriptAllowRowLocksIndexOption : SqlScriptOnOffIndexOption<SqlAllowRowLocksIndexOption>
        {
        #region ctor{IServiceProvider,SqlAllowRowLocksIndexOption}
        public SqlScriptAllowRowLocksIndexOption(IServiceProvider context,SqlAllowRowLocksIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }