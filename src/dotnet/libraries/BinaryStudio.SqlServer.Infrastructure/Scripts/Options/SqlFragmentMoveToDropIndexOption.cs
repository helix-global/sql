using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(MoveToDropIndexOption))]
    internal sealed class SqlFragmentMoveToDropIndexOption : SqlFragmentIndexOption<MoveToDropIndexOption>
        {
        #region ctor{IServiceProvider,MoveToDropIndexOption}
        public SqlFragmentMoveToDropIndexOption(IServiceProvider context,MoveToDropIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }