using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(MaxDurationOption))]
    internal sealed class SqlFragmentMaxDurationOption : SqlFragmentIndexOption<MaxDurationOption>
        {
        #region ctor{IServiceProvider,MaxDurationOption}
        public SqlFragmentMaxDurationOption(IServiceProvider context,MaxDurationOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }