using System;
using Microsoft.SqlServer.Management.SqlParser.SqlCodeDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(SqlAllowPageLocksIndexOption))]
    internal sealed class SqlScriptAllowPageLocksIndexOption : SqlScriptOnOffIndexOption<SqlAllowPageLocksIndexOption>
        {
        #region ctor{IServiceProvider,SqlAllowPageLocksIndexOption}
        public SqlScriptAllowPageLocksIndexOption(IServiceProvider context,SqlAllowPageLocksIndexOption source)
            : base(context, source)
            {
            }
        #endregion
        }
    }