using System;
using Microsoft.SqlServer.TransactSql.ScriptDom;

namespace BinaryStudio.SqlServer.Infrastructure
    {
    [SqlScriptObject(typeof(FileStreamOnDropIndexOption))]
    internal sealed class SqlFragmentFileStreamOnDropIndexOption : SqlFragmentIndexOption<FileStreamOnDropIndexOption>
        {
        #region ctor{IServiceProvider,FileStreamOnDropIndexOption}
        public SqlFragmentFileStreamOnDropIndexOption(IServiceProvider context,FileStreamOnDropIndexOption source)
            : base(context,source)
            {
            }
        #endregion
        }
    }