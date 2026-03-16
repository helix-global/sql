using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    using FieldAttribute=SqlModelFieldMappingAttribute;

    [SqlScriptObject(typeof(VectorTypeIndexOption))]
    internal sealed class SqlFragmentVectorTypeIndexOption : SqlFragmentIndexOption<VectorTypeIndexOption>
        {
        #region ctor{IServiceProvider,VectorTypeIndexOption}
        public SqlFragmentVectorTypeIndexOption(IServiceProvider context,VectorTypeIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }